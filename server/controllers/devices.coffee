Client = require('request-json').JsonClient
passport = require 'passport'
deviceManager = require '../models/device'
{getProxy} = require '../lib/proxy'


couchdbHost = process.env.COUCH_HOST or 'localhost'
couchdbPort = process.env.COUCH_PORT or '5984'

hostDS = 'localhost'
portDS = '9101'
clientDS = new Client "http://localhost:9101/"

if process.env.NODE_ENV is "production" or process.env.NODE_ENV is "test"
    clientDS.setBasicAuth process.env.NAME, process.env.TOKEN

defaultPermissions =
    'file': 'Usefull to synchronize your files',
    'folder': 'Usefull to synchronize your folder',
    'notification': 'Usefull to synchronize your notification'
    'binary': 'Usefull to synchronize your files'


# Define random function for application's token
randomString = (length) ->
    string = ""
    while (string.length < length)
        string = string + Math.random().toString(36).substr(2)
    return string.substr 0, length

# helper functions
extractCredentials = (header) ->
    if header?
        authDevice = header.replace 'Basic ', ''
        authDevice = new Buffer(authDevice, 'base64').toString 'ascii'
        return authDevice.split ':'
    else
        return ["", ""]

getCredentialsHeader = ->
    credentials = "#{process.env.NAME}:#{process.env.TOKEN}"
    basicCredentials = new Buffer(credentials).toString 'base64'
    return "Basic #{basicCredentials}"

# controller actions
module.exports.create = (req, res, next) ->
    authenticator = passport.authenticate 'local', (err, user) ->
        if err
            console.log err
            next err
        else if user is undefined or not user
            error = new Error "Bad credentials"
            error.status = 401
            next error
        else
            # Send request to the Data System
            device = req.body
            # Check if name is correctly declared
            if not device?.login?
                error = new Error "Name isn't defined in req.body.login"
                error.status = 400
                next error
            else
                # Create device
                device.docType = "Device"

                # Check if an other device hasn't the same name
                clientDS.post "request/device/byLogin/", key: device.login, (err, result, body) ->
                    if err
                        next err
                    else if body.length isnt 0
                        error = new Error "This name is already used"
                        error.status = 400
                        next error
                    else
                        # Create device
                        device.docType = "Device"
                        clientDS.post "data/", device, (err, result, docInfo) ->
                            if err
                                next err
                            else
                                # Create access for this device
                                access =
                                    login: device.login
                                    password: randomString 32
                                    app: docInfo._id
                                    permissions: device.permissions or defaultPermissions
                                clientDS.post 'access/', access, (err, result, body) ->
                                    console.log err if err?
                                    data =
                                        password: access.password
                                        login: device.login
                                        permissions: access.permissions
                                    # Return access to device
                                    res.send 201, data

    # Authenticate the request
    [username, password] = extractCredentials req.headers['authorization']

    # Initialize user
    user = {}
    user.body = password: password

    req.headers['authorization'] = undefined
    # Check if request is authenticated
    authenticator user, res


module.exports.update = (req, res, next) ->
    authenticator = passport.authenticate 'local', (err, user) ->
        if err
            console.log err
            next err
        else if user is undefined or not user
            error = new Error "Bad credentials"
            error.status = 401
            next error
        else
            # Send request to the Data System
            login = req.params.login
            device = req.body
            # Check if name is correctly declared
            if not login?
                error = new Error "Name isn't defined in req.body.login"
                error.status = 400
                next error
            else
                # Create device
                device.docType = "Device"

                # Check if an other device hasn't the same name
                clientDS.post "request/device/byLogin/", key: login, (err, result, body) ->
                    if err
                        next err
                    else if body.length is 0
                        error = new Error "This device doesn't exist"
                        error.status = 400
                        next error
                    else
                        clientDS.post "request/access/byApp/", key: body[0].id, (err, result, accesses) ->
                            # Update access for this device
                            access =
                                login: device.login
                                password: randomString 32
                                app: body[0]._id
                                permissions: device.permissions or defaultPermissions
                            clientDS.put "access/#{accesses[0].id}/", access, (err, result, body) ->
                                console.log err if err?
                                data =
                                    password: access.password
                                    login: device.login
                                    permissions: access.permissions
                                # Return access to device
                                res.send 200, data

    # Authenticate the request
    [username, password] = extractCredentials req.headers['authorization']

    # Initialize user
    user = {}
    user.body = password: password

    req.headers['authorization'] = undefined
    # Check if request is authenticated
    authenticator user, res

module.exports.remove = (req, res , next) ->
    authenticator = passport.authenticate 'local', (err, user) ->
        if err
            console.log err
            next err
        else if user is undefined or not user
            error = new Error "Bad credentials"
            error.status = 401
            next error
        else
            # Send request to the Data System
            login = req.params.login
            # Check if an other device hasn't the same name
            clientDS.post "request/device/byLogin/", key: login, (err, result, body) ->
                if err
                    next err
                else if body.length is 0
                    error = new Error "This device doesn't exist"
                    error.status = 400
                    next error
                else
                    id = body[0].id
                    # Remove Access
                    console.log 'remove Access'
                    clientDS.del "access/#{id}/", (err, result, body) ->
                        if err?
                            error = new Error err
                            error.status = 400
                            next error
                        else
                            console.log 'remove Device'
                            # Remove Device
                            clientDS.del "data/#{id}/", (err, result, body) ->
                                if err?
                                    error = new Error err
                                    error.status = 400
                                    next error
                                else
                                    console.log 'end'
                                    res.send 200

    # Authenticate the request
    [username, password] = extractCredentials req.headers['authorization']

    # Initialize user
    user = {}
    user.body = password: password

    req.headers['authorization'] = undefined
    # Check if request is authenticated
    authenticator user, res

module.exports.replication = (req, res, next) ->

    # Authenticate the request
    [username, password] = extractCredentials req.headers['authorization']
    deviceManager.isAuthenticated username, password, (auth) ->
        if auth
            # Forward request for DS.
            getProxy().web req, res, target: "http://#{hostDS}:#{portDS}"
        else
            error = new Error "Request unauthorized"
            error.status = 401
            next error

# Old replication
# Patch : 01/05/14
module.exports.oldReplication = (req, res, next) ->

    # Authenticate the request
    [username, password] = extractCredentials req.headers['authorization']
    deviceManager.isAuthenticated username, password, (auth) ->
        if auth
            # Add his creadentials for CouchDB
            if process.env.NODE_ENV is "production"
                req.headers['authorization'] = getCredentialsHeader()
            else
                # Do not forward 'authorization' header in other environments
                # in order to avoid wrong authentications in CouchDB
                req.headers['authorization'] = null

            # Forward request to Couch
            # the request didn't go through the DS because for some unknown
            # reason, the double proxy was failing. We should try again with
            # the new node-http-proxy version.
            # That would make a device an application that is not running on
            # the Cozy itself which is awesome because it would be easy to
            # add a permission layer and makes Cozy a true open platform
            # (easy desktop/mobile clients)
            getProxy().web req, res, target: "http://#{couchdbHost}:#{couchdbPort}"
        else
            error = new Error "Request unauthorized"
            error.status = 401
            next error