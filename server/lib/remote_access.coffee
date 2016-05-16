Client = require('request-json').JsonClient
logger = require('printit')
    date: false
    prefix: 'lib:remote_access'

# Keep in memory the accesses
cache = {}

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
updateCredentials = module.exports.updateCredentials = (callback) ->
    # Retrieve all accesses
    client.post "request/access/all/", {}, (err, res, accesses) ->
        cache = {}
        if err?
            logger.error err
            callback? err
        else
            if accesses?
                # Retrieve all accesses
                for access in accesses
                    cache[access.value.login] = access.value.token

            callback?()


# Check if <login>:<password> is authenticated
module.exports.isAuthenticated = (header, callback) ->
    [login, password] = extractCredentials header
    isPresent = cache[login]? and cache[login] is password

    if isPresent or process.env.NODE_ENV is "development"
        callback true
    else
        updateCredentials () ->
            callback(cache[login]? and cache[login] is password)


# Check if a sharing recipient is authenticated by its token
# This differs from the regular authentication as the recipient does not have
# any access on the documents, but can still send some sharing requests
module.exports.isTargetAuthenticated = (credential, callback) ->
    unless credential.shareID? and credential.token?
        return callback false

    # Get the sharing doc
    client.get "data/#{credential.shareID}", (err, result, doc) ->
        if err or not doc?.targets?
            callback false
        else
            # Get the target by its token
            target = doc.targets.filter (t) ->
                t.token is credential.token or t.preToken is credential.token
            target = target[0]

            callback(target?, doc, target)



