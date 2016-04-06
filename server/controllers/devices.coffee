Client = require('request-json').JsonClient
passport = require 'passport'
urlHelper = require 'cozy-url-sdk'
remoteAccess = require '../lib/remote_access'
appManager = require '../lib/app_manager'
{getProxy} = require '../lib/proxy'

log = require('printit')
    date: false
    prefix: 'controllers:devices'


clientDS = new Client urlHelper.dataSystem.url()

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
            cb null, body[0]?.value

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
    authHeader = req.headers['authorization']
    [username, password] = remoteAccess.extractCredentials authHeader
    # Initialize user
    user = {}
    user.body =
        username: username
        password: password
    req.headers['authorization'] = undefined
    cb user



# Create device :
#       * create device document
#       * create device access
createDevice = (device, cb) ->
    device.docType = "Device"
    access =
        login: device.login
        password: randomString 32
        permissions: device.permissions or defaultPermissions
    # Create device document
    delete device.permissions
    clientDS.post "data/", device, (err, result, docInfo) ->
        return cb(err) if err?
        # Create access for this device
        access.app = docInfo._id
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
updateDevice = (oldDevice, device, callback) ->

    path = "request/access/byApp/"
    clientDS.post path, key: oldDevice._id, (err, result, accesses) ->

        return callback err if err

        if accesses.length is 0
            error = new Error "No access to this app."
            return callback error

        oldAccess = accesses[0].value

        # Update access for this device
        access =
            login: oldAccess.login
            password: oldAccess.token
            app: oldAccess.app
            permissions: device.permissions or oldAccess.permissions

        path = "access/#{access.app}/"
        clientDS.put path, access, (err, result, body) ->

            return callback err if err

            oldDevice.login = device.login
            delete oldDevice.permissions
            path = "data/#{oldDevice._id}"
            clientDS.put path, oldDevice, (err, result, body) ->

                data =
                    login: access.login
                    password: access.password
                    permissions: access.permissions

                # Return access to device
                callback err, data


# Remove device :
#       * remove device access
#       * remove device document
removeDevice = (device, cb) ->
    id = device._id
    # Remove Access
    clientDS.del "access/#{id}/", (err, result, body) ->
        if err?
            error = new Error err
            error.status = 400
            cb error
        else
            # Remove Device
            clientDS.del "data/#{id}/", (err, result, body) ->
                if err?
                    error = new Error err
                    error.status = 400
                    cb error
                else
                    cb null


## Controller actions

module.exports.create = (req, res, next) ->

    # Check if user is authenticated
    authenticator = passport.authenticate 'local', (err, user) ->
        if err
            log.warn err
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
                        res.status(201).send data


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
                        res.status(200).send data

    initAuth req, (user) ->
        # Check if request is authenticated
        authenticator user, res


module.exports.remove = (req, res, next) ->
    # Authenticate the request
    authHeader = req.headers['authorization']
    [username, password] = remoteAccess.extractCredentials authHeader
    deviceName = req.params.login

    remove = ->
        checkLogin deviceName, true, (err, device) ->
            return next err if err?
            # Remove device
            removeDevice device, (err) ->
                if err?
                    next err
                else
                    res.sendStatus 204

    if deviceName is username
        remoteAccess.isAuthenticated authHeader, (auth) ->
            if auth
                remove()
            else
                error = new Error "Request unauthorized"
                error.status = 401
                next error
    else
        authenticator =
            passport.authenticate 'local', (err, user) ->
                if err
                    console.log err
                    next err
                else if user is undefined or not user
                    error = new Error "Bad credentials"
                    error.status = 401
                    next error
                else
                    remove()

        initAuth req, (user) ->
            # Check if request is authenticated
            authenticator user, res


module.exports.replication = (req, res, next) ->
    # Authenticate the request
    remoteAccess.isAuthenticated req.headers['authorization'], (auth) ->
        if auth
            # Forward request for DS.
            getProxy().web req, res, target: urlHelper.dataSystem.url()
        else
            error = new Error "Request unauthorized"
            error.status = 401
            next error


module.exports.dsApi = (req, res, next) ->
    # Authenticate the request
    authHeader = req.headers['authorization'] or req.query.authorization
    remoteAccess.isAuthenticated authHeader, (auth) ->
        if auth
            # Forward request for DS.
            req.url = req.url.replace 'ds-api/', ''
            getProxy().web req, res, target: urlHelper.dataSystem.url()
        else
            error = new Error "Request unauthorized"
            error.status = 401
            next error


module.exports.getVersions = (req, res, next) ->
    # Authenticate the request
    remoteAccess.isAuthenticated req.headers['authorization'], (auth) ->
        if auth
            # Forward request for DS.
            appManager.versions (err, apps) ->
                if err?
                    error = new Error err
                    error.status = 400
                    next error
                else
                    res.status(200).send apps
        else
            error = new Error "Request unauthorized"
            error.status = 401
            next error


# Old replication
# Patch : 01/05/14
module.exports.oldReplication = (req, res, next) ->

    # Authenticate the request
    remoteAccess.isAuthenticated req.headers['authorization'], (auth) ->
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
            getProxy().web req, res, target: urlHelper.couch.url()
        else
            error = new Error "Request unauthorized"
            error.status = 401
            next error
