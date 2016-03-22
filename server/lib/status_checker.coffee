async = require 'async'
urlHelper = require 'cozy-url-sdk'

JsonClient = require('request-json').JsonClient
User = require '../models/user'

couchUrl      = urlHelper.couch.url() + "/"
controllerUrl = urlHelper.controller.url() + "/"
dataSystemUrl = urlHelper.dataSystem.url() + "/"
homeUrl       = urlHelper.home.url() + "/"
proxyUrl      = urlHelper.proxy.url() + "/"

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
            @getChecker "controller", controllerUrl
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
