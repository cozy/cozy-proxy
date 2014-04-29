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
    cache = {}
    Device.request 'all', (err, devices) ->
        if err then logger.error err

        if devices?
            for device in devices
                cache[device.login] = device.password

        callback() if callback?

Device.isAuthenticated = (login, password, callback) ->
    return cache[login]? and cache[login] is password
