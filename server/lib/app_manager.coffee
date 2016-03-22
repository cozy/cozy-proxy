Client = require('request-json').JsonClient
urlHelper = require 'cozy-url-sdk'
logger = require('printit')
    date: false
    prefix: 'lib:app_manager'

class AppManager

    isStarting: []

    constructor: ->
        @client = new Client urlHelper.home.url()
        @router = require './router'

    # check if an application's state, start the app if requested
    ensureStarted: (slug, shouldStart, callback) ->
        routes = @router.getRoutes()
        if not routes[slug]?
            logger.error "App #{slug} unknown"
            callback code: 404, msg: 'app unknown'
            return
        switch routes[slug].state
            when 'broken'
                logger.error "App #{slug} broken"
                callback code: 500, msg: 'app broken'
            when 'installing'
                callback code: 404, msg: 'app is still installing'
            when 'installed'
                callback null, routes[slug]
            when 'stopped'
                if shouldStart and not @isStarting[slug]?
                    @isStarting[slug] = true
                    @startApp slug, (err, response) =>
                        delete @isStarting[slug]
                        if err?
                            logger.error "cannot start app #{slug} : #{err}"
                            callback code: 500, msg: "cannot start app : #{err}"
                        else
                            callback null, response
                else
                    logger.error "cannot start app #{slug} : won't start"
                    callback code: 500, msg: 'wont start'

            else
                state = routes[slug].state
                logger.error "#{slug}: incorrect app state: #{state}"
                callback code: 500, msg: 'incorrect app state'


    # request home to start a new app
    startApp: (slug, callback) ->
        logger.info "Starting app #{slug}"
        @client.post "api/applications/#{slug}/start", {}, (err, res, data) =>

            err = err or data.msg if data?.error

            if err? or res.statusCode isnt 200
                msg = "An error occurred while starting the app #{slug}"
                logger.error "#{msg} -- #{err}"
                callback err
            else
                logger.info "App #{slug} successfully started."
                routes = @router.getRoutes()
                routes[slug] =
                    port: data.app.port
                    state: data.app.state
                callback null, routes[slug]

    versions: (callback) ->
        @client.get "api/applications/stack", (error, res, apps) ->
            return callback error if error?
            callback null, apps.rows.map (app) ->
                return "#{app.name}: #{app.version}"

module.exports = new AppManager()
