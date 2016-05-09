Client = require('request-json').JsonClient
logger = require('printit')
    date: false
    prefix: 'lib:remote_access'

# Keep in memory the logins/passwords
devices = {}
sharings = {}

# Initialize ds client : useful to retrieve all accesses
dsHost = 'localhost'
dsPort = '9101'
client = new Client "http://#{dsHost}:#{dsPort}/"
if process.env.NODE_ENV is "production" or process.env.NODE_ENV is "test"
    client.setBasicAuth process.env.NAME, process.env.TOKEN


# helper function
extractCredentials = module.exports.extractCredentials = (header) ->
    if header?
        authDevice = header.replace 'Basic ', ''
        authDevice = new Buffer(authDevice, 'base64').toString 'utf8'
        # username should be 'owner', a device name or a sharing login
        username = authDevice.substr(0, authDevice.indexOf(':'))
        password = authDevice.substr(authDevice.indexOf(':') + 1)
        return [username, password]
    else
        return ["", ""]


# Update credentials in memory
updateCredentials = module.exports.updateCredentials = (model, callback) ->
    if model is 'Device'
        path = "request/device/all"
        devices = {}
        cache = devices
    else if model is "Sharing"
        path = "request/sharing/all"
        sharings = {}
        cache = sharings
    else
        callback() if callback?

    # Retrieve all model's results
    client.post path, {}, (err, res, results) ->
        if err? or results?.error?
            logger.error err
            callback? err
        else
            if results?
                # Retrieve all accesses
                results = results.map (result) ->
                    return result.id
                client.post "request/access/byApp/", {}, (err, res, accesses) ->
                    if err?
                        logger.error err
                        callback err
                    else
                        for access in accesses
                            # Check if access correspond to a result
                            if access.key in results
                                cache[access.value.login] = access.value.token
                    callback?()
            else
                callback()?


# Check if <login>:<password> is authenticated for a device
module.exports.isDeviceAuthenticated = (header, callback) ->
    [login, password] = extractCredentials header
    isPresent = devices[login]? and devices[login] is password

    if isPresent or process.env.NODE_ENV is "development"
        callback true
    else
        updateCredentials 'Device', ->
            callback(devices[login]? and devices[login] is password)


# Check if <login>:<password> is authenticated for a sharing
module.exports.isSharingAuthenticated = (header, callback) ->
    [login, password] = extractCredentials header
    isPresent = sharings[login]? and sharings[login] is password

    if isPresent or process.env.NODE_ENV is "development"
        callback true
    else
        updateCredentials 'Sharing', ->
            callback(sharings[login]? and sharings[login] is password)


# Check if a sharing recipient is authenticated by its token
# This differs from the regular authentication as the recipient does not have
# any access on the documents, but can still send some sharing requests
module.exports.isTargetAuthenticated = (credential, callback) ->
    console.log 'credentials : ' + JSON.stringify credential
    unless credential.shareID? and credential.token?
        return callback false

    # Get the sharing doc
    client.get "data/#{credential.shareID}", (err, result, doc) ->
        if err or not doc?.targets?
            callback false
        else
            console.log JSON.stringify doc.targets
            # Get the target by its token
            target = doc.targets.filter (t) ->
                t.token is credential.token or t.preToken is credential.token
            target = target[0]

            callback(target?, doc, target)



