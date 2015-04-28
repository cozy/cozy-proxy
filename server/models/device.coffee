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
client = new Client "http://localhost:9101/"

if process.env.NODE_ENV is "production" or process.env.NODE_ENV is "test"
    client.setBasicAuth process.env.NAME, process.env.TOKEN

Device.update = (callback) ->
    # Retrieve all devices
    Device.request 'all', (err, devices) ->
        cache = {}
        if err?
            logger.error err
            callback err
        else
            if devices?
                # Retrieve all access
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

Device.isAuthenticated = (login, password, callback) ->
    isPresent = cache[login]? and cache[login] is password
    if isPresent
        callback true
    else
        @update () ->
            callback(cache[login]? and cache[login] is password)
