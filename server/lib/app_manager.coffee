Client = require('request-json').JsonClient
logger = require('printit')
            date: false
            prefix: 'lib:app_manager'

class AppManager

    constructor: ->
        homePort = process.env.DEFAULT_REDIRECT_PORT
        @client = new Client "http://localhost:#{homePort}/"
        @router = require './router'

    # check if an application's state, start the app if requested
    ensureStarted: (slug, shouldStart, callback) ->
        routes = @router.getRoutes()
        if not routes[slug]?
            callback code: 404, msg:'app unknown'
            return

        switch routes[slug].state
            when 'broken'
                callback code: 500, msg: 'app broken'
            when 'installing'
                callback code: 404, msg: 'app is still installing'
            when 'installed'
                callback null, routes[slug].port
            when 'stopped'
                if shouldStart
                    @startApp slug, (err, port) ->
                        if err?
                            callback code: 500, msg: "cannot start app : #{err}"
                        else
                            callback null, port
                else
                    callback code: 500, msg: 'wont start'

            else callback code: 500, msg: 'incorrect app state'

    # request home to start a new app
    startApp: (slug, callback) ->
        logger.info "Starting app #{slug}"
        @client.post "api/applications/#{slug}/start", {}, (err, res, data) =>

            err = err or data.msg if data.error

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
                callback null, data.app.port

module.exports = new AppManager()
