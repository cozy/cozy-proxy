americano = require 'americano-cozy'
logger = require('printit')
            date: false
            prefix: 'models:device'

module.exports = Device = americano.getModel 'Device',
    login: String
    password: String
    configuration: Object

cache = {}

Device.update = (callback) ->
    Device.request 'all', (err, devices) ->
        cache = {}
        if err?
            logger.error err
            callback err
        else
            if devices?
                for device in devices
                    cache[device.login] = device.password

            callback() if callback?

Device.isAuthenticated = (login, password, callback) ->
    isPresent = cache[login]? and cache[login] is password
    if isPresent
        callback true
    else
        @update () ->
            callback(cache[login]? and cache[login] is password)
