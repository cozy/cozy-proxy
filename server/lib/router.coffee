util = require 'util'
Client = require('request-json').JsonClient
logger = require('printit')
    date: false
    prefix: 'lib:router'

class Router

    routes: {}

    constructor: ->
        homePort = process.env.DEFAULT_REDIRECT_PORT
        @client = new Client "http://localhost:#{homePort}/"

    getRoutes: -> return @routes

    displayRoutes: (callback) ->
        for slug, route of @routes
            if route.type is 'static'
                logger.info "#{slug} (#{route.state}) on type #{route.type}"
            else
                logger.info "#{slug} (#{route.state}) on port #{route.port}"

        callback() if callback?

    reset: (callback) ->
        logger.info 'Start resetting routes...'
        @routes = {}
        @client.get "api/applications/", (error, res, apps) =>
            if error? or apps.error?
                logger.error "Cannot retrieve applications list."
                logger.error util.inspect(error) or apps.msg
                return callback error or apps.msg

            try
                for app in apps.rows
                    @routes[app.slug] = {}
                    # add path to be able to read the static file
                    if app.type is 'static'
                        @routes[app.slug].type = app.type
                        @routes[app.slug].path = app.path
                    else
                        @routes[app.slug].port = app.port if app.port?
                    @routes[app.slug].state = app.state if app.state?
                logger.info "Routes have been successfully reset."
                callback()
            catch err
                logger.error "Oops, something went wrong during routes reset."
                callback err

module.exports = new Router()
