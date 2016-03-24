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
            return callback err
        else
            if accesses?
                # Retrieve all accesses
                for access in accesses
                    logger.info "#login: #{access.value.login}"
                    logger.info "#token: #{access.value.token}"
                    cache[access.value.login] = access.value.token

        callback() if callback?

# Check if device <login>:<password> is authenticated
Device.isAuthenticated = (login, password, callback) ->
    logger.info "#username: #{login}"
    logger.info "#password: #{password}"
    isPresent = cache[login]? and cache[login] is password
    logger.info "#isPresent: #{isPresent ? 'true' : 'false' }"
    logger.info "NODE_ENV: #{process.env.NODE_ENV}"
    if isPresent or process.env.NODE_ENV is "development"
        callback true
    else
        @update ->
            logger.info "#cache"
            logger.info cache
            callback cache[login]? is password
