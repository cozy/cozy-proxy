Client = require('request-json').JsonClient
passport = require 'passport'
deviceManager = require '../models/device'
appManager = require '../lib/app_manager'
{getProxy} = require '../lib/proxy'


couchdbHost = process.env.COUCH_HOST or 'localhost'
couchdbPort = process.env.COUCH_PORT or '5984'

dsHost = 'localhost'
dsPort = '9101'
clientDS = new Client "http://#{dsHost}:#{dsPort}/"

if process.env.NODE_ENV is "production" or process.env.NODE_ENV is "test"
    clientDS.setBasicAuth process.env.NAME, process.env.TOKEN


# If device doesn't precise its permissions, use default permissions.
defaultPermissions =
    'File':
        'description': 'Usefull to synchronize your files'
    'Folder':
        'description': 'Usefull to synchronize your folder'
    'Binary':
        'description': 'Usefull to synchronize the content of your files'
    'Notification':
        'description': 'Usefull to synchronize cozy notifications'


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
        authDevice = new Buffer(authDevice, 'base64').toString 'utf8'
        # username should be 'owner'
        username = authDevice.substr(0, authDevice.indexOf(':'))
        password = authDevice.substr(authDevice.indexOf(':') + 1)
        return [username, password]
    else
        return ["", ""]

# Get proxy crededntials : usefull for device creation
getCredentialsHeader = ->
    credentials = "#{process.env.NAME}:#{process.env.TOKEN}"
    basicCredentials = new Buffer(credentials).toString 'base64'
    return "Basic #{basicCredentials}"

# Check if device with <login> already exists
deviceExists = (login, cb) ->
    clientDS.post "request/device/byLogin/", key: login, (err, result, body) ->
        if err
            cb err
        else if body.length is 0
            cb null, false
        else
            cb null, body[0]

checkLogin = (login, wantExist, cb)->
    if not login?
        error = new Error "Name isn't defined in req.body.login"
        error.status = 400
        cb error
    else
        # Check if an other device hasn't the same name
        deviceExists login, (err, device) ->
            if err
                next err
            else if device
                if wantExist
                    cb null, device
                else
                    error = new Error "This name is already used"
                    error.status = 400
                    cb error
            else
                if wantExist
                    error = new Error "This device doesn't exist"
                    error.status = 400
                    cb error
                else
                    cb()

initAuth = (req, cb) ->
    # Authenticate the request
    [username, password] = extractCredentials req.headers['authorization']
    # Initialize user
    user = {}
    user.body = password: password
    req.headers['authorization'] = undefined
    cb user



# Create device :
#       * create device document
#       * create device access
createDevice = (device, cb) ->
    device.docType = "Device"
    # Create device document
    clientDS.post "data/", device, (err, result, docInfo) ->
        return cb(err) if err?
        # Create access for this device
        access =
            login: device.login
            password: randomString 32
            app: docInfo._id
            permissions: device.permissions or defaultPermissions
        clientDS.post 'access/', access, (err, result, body) ->
            return cb(err) if err?
            data =
                password: access.password
                login: device.login
                permissions: access.permissions
            # Return access to device
            cb null, data


# Update device :
#       * update device access
updateDevice = (oldDevice, device, cb) ->
    path = "request/access/byApp/"
    clientDS.post path, key: oldDevice.id, (err, result, accesses) ->
        # Update access for this device
        access =
            login: device.login
            password: randomString 32
            app: oldDevice.id
            permissions: device.permissions or defaultPermissions
        path = "access/#{accesses[0].id}/"
        clientDS.put path, access, (err, result, body) ->
            if err?
                console.log err
                error = new Error err
                cb error
            else
                data =
                    password: access.password
                    login: device.login
                    permissions: access.permissions
                # Return access to device
                cb null, data


# Remove device :
#       * remove device access
#       * remove device document
removeDevice = (device, cb) ->
    id = device.id
    # Remove Access
    clientDS.del "access/#{id}/", (err, result, body) ->
        if err?
            error = new Error err
            error.status = 400
            cd error
        else
            # Remove Device
            clientDS.del "data/#{id}/", (err, result, body) ->
                if err?
                    error = new Error err
                    error.status = 400
                    cd error
                else
                    cb null




## Controller actions

module.exports.create = (req, res, next) ->

    # Check if user is authenticated
    authenticator = passport.authenticate 'local', (err, user) ->
        if err
            console.log err
            next err
        else if user is undefined or not user
            error = new Error "Bad credentials"
            error.status = 401
            next error
        else
            # Check if name is correctly declared and device doesn't exist
            device = req.body
            checkLogin device.login, false, (err) ->
                return next err if err?
                # Create device
                device.docType = "Device"
                createDevice device, (err, data) ->
                    if err?
                        next err
                    else
                        res.send 201, data


    initAuth req, (user) ->
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
            # Check if name is correctly declared and device exists
            login = req.params.login
            device = req.body
            checkLogin login, true, (err, oldDevice) ->
                return next err if err?
                # Update device
                device.docType = "Device"
                updateDevice oldDevice, device, (err, data) ->
                    if err?
                        next err
                    else
                        res.send 200, data

    initAuth req, (user) ->
        # Check if request is authenticated
        authenticator user, res


module.exports.remove = (req, res, next) ->

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

            checkLogin login, true, (err, device) ->
                return next err if err?
                # Remove device
                removeDevice device, (err) ->
                    if err?
                        next err
                    else
                        res.send 204

    initAuth req, (user) ->
        # Check if request is authenticated
        authenticator user, res


module.exports.replication = (req, res, next) ->
    # Authenticate the request
    [username, password] = extractCredentials req.headers['authorization']
    deviceManager.isAuthenticated username, password, (auth) ->
        if auth
            # Forward request for DS.
            getProxy().web req, res, target: "http://#{dsHost}:#{dsPort}"
        else
            error = new Error "Request unauthorized"
            error.status = 401
            next error


module.exports.dsApi = (req, res, next) ->
    # Authenticate the request
    [username, password] = extractCredentials req.headers['authorization']
    deviceManager.isAuthenticated username, password, (auth) ->
        if auth
            # Forward request for DS.
            req.url = req.url.replace 'ds-api/', ''
            getProxy().web req, res, target: "http://#{dsHost}:#{dsPort}"
        else
            error = new Error "Request unauthorized"
            error.status = 401
            next error


module.exports.getVersions = (req, res, next) ->
    # Authenticate the request
    [username, password] = extractCredentials req.headers['authorization']
    deviceManager.isAuthenticated username, password, (auth) ->
        if auth
            # Forward request for DS.
            appManager.versions (err, apps) ->
                if err?
                    error = new Error err
                    error.status = 400
                    next error
                else
                    res.send apps, 200
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
            target = "http://#{couchdbHost}:#{couchdbPort}"
            getProxy().web req, res, target: target
        else
            error = new Error "Request unauthorized"
            error.status = 401
            next error
