Client = require('request-json').JsonClient
americano = require 'americano-cozy'
async = require 'async'
logger = require('printit')
            date: false
            prefix: 'models:device'

module.exports = Device = americano.getModel 'Device',
    login: String
    password: String
    configuration: Object

cache = {}
# Initialize ds client : usefull to retrieve all accesses
dsHost = 'localhost'
dsPort = '9101'
client = new Client "http://#{dsHost}:#{dsPort}/"
if process.env.NODE_ENV is "production" or process.env.NODE_ENV is "test"
    client.setBasicAuth process.env.NAME, process.env.TOKEN

# Update device in cache
Device.update = (callback) ->
    # Retrieve all devices
    Device.request 'all', (err, devices) ->
        cache = {}
        if err?
            logger.error err
            callback err
        else
            if devices?
                # Retrieve all accesses
                devices = devices.map (device) -> return device.id
                client.post "request/access/byApp/", {}, (err, res, accesses) ->
                    if err?
                        logger.error err
                        callback err
                    else
                        for access in accesses
                            # Check if access correspond to a device
                            if access.key in devices
                                cache[access.value.login] = access.value.token
                    callback() if callback?
            else
                callback() if callback?

# Check if device <login>:<password> is authenticated
Device.isAuthenticated = (login, password, callback) ->
    isPresent = cache[login]? and cache[login] is password
    if isPresent or process.env.NODE_ENV is "development"
        callback true
    else
        @update () ->
            callback(cache[login]? and cache[login] is password)
