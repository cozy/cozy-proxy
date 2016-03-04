Client = require('request-json').JsonClient
cozydb = require 'cozydb'
async = require 'async'
logger = require('printit')
    date: false
    prefix: 'models:device'

module.exports = Device = cozydb.getModel 'Device',
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
    # Retrieve all accesses
    client.post "request/access/all/", {}, (err, res, accesses) ->
        cache = {}
        if err?
            logger.error err
            callback err
        else
            if accesses?
                # Retrieve all accesses
                for access in accesses
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
        @update ->
            callback(cache[login]? and cache[login] is password)
