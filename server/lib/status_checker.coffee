async = require 'async'

JsonClient = require('request-json').JsonClient
User = require '../models/user'

couchUrl = "http://localhost:5984/"
controllerUrl = "http://localhost:9002/"
dataSystemUrl = "http://localhost:9101/"
indexerUrl = "http://localhost:9102/"
homePort = process.env.DEFAULT_REDIRECT_PORT
homeUrl = "http://localhost:#{homePort}/"
proxyUrl = "http://localhost:9104/"

# Class used to check the state of the main modules of the Cozy.
class StatusChecker

    # The client use to test the state of the modules.
    client: new JsonClient()

    # By default everything is down.
    status:
        couchdb: false
        datasystem: false
        controller: false
        indexer: false
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
            @getChecker "controller", controllerUrl, "version"
            @getChecker "datasystem", dataSystemUrl
            @getChecker "indexer", indexerUrl
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
                    @status[app] = code is 200 or code is 403
                else
                    @status[app] = false

                callback()
            , false
module.exports = new StatusChecker()
