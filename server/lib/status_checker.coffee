async = require 'async'

JsonClient = require('request-json').JsonClient
User = require '../models/user'

couchdbHost    = process.env.COUCH_HOST or 'localhost'
couchdbPort    = process.env.COUCH_PORT or '5984'
proxyHost      = process.env.PROXY_HOST or 'localhost'
proxyPort      = process.env.PROXY_PORT or '9104'
controllerHost = process.env.CONTROLLER_HOST or 'localhost'
controllerPort = process.env.CONTROLLER_PORT or '9002'
dataSystemHost = process.env.DATASYSTEM_HOST or 'localhost'
dataSystemPort = process.env.DATASYSTEM_PORT or '9101'
homeHost       = process.env.HOME_HOST or 'localhost'
homePort       = process.env.DEFAULT_REDIRECT_PORT

couchUrl      = "http://#{couchdbHost}:#{couchdbPort}/"
controllerUrl = "http://#{controllerHost}:#{controllerPort}/"
dataSystemUrl = "http://#{dataSystemHost}:#{dataSystemPort}/"
homeUrl       = "http://#{homeHost}:#{homePort}/"
proxyUrl      = "http://#{proxyHost}:#{proxyPort}/"

# Class used to check the state of the main modules of the Cozy.
class StatusChecker

    # The client use to test the state of the modules.
    client: new JsonClient()

    # By default everything is down.
    status:
        couchdb: false
        datasystem: false
        controller: false
        home: false
        registered: false

    # Check status of the main modules by sending them an HTTP request
    # If a 200 response, the module is considered as OK. If not, it is
    # considered as down.
    # Then it checks if user is registered and add it to the status
    # informations.
    checkAllStatus: (callback) ->
        @status[field] = false for field, value of @status

        async.series [
            @getChecker "couchdb", couchUrl
            @getChecker "controller", controllerUrl, "drones/running"
            @getChecker "datasystem", dataSystemUrl
            @getChecker "home", homeUrl
            @getChecker "proxy", proxyUrl, "routes"
        ], =>
            User.first (err, user) =>
                if not user? or err
                    callback null, @status
                else
                    @status.registered = true
                    callback null, @status

    getChecker: (app, url, path="") ->
        (callback) =>
            @client.host = url
            @client.get path, (err, res, body) =>
                if res?
                    code = res.statusCode
                    @status[app] = code in [200, 401, 403]
                else
                    @status[app] = false

                callback()
            , false
module.exports = new StatusChecker()
