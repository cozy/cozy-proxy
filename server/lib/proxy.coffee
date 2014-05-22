httpProxy = require 'http-proxy'
async = require 'async'
passport = require 'passport'
config = require '../config'
logger = require('printit')
    date: false
    prefix: 'lib:proxy'

router = require './router'
localization = require './localization_manager'
errorHandler = require '../middlewares/errors'

# singleton variable
proxy = null

module.exports.getProxy = -> return proxy

module.exports.initializeProxy = (app, server) ->

    # create proxy server
    proxy = httpProxy.createProxyServer()

    # proxy error handling
    proxy.on 'error', (err, req, res) ->
        err = new Error err
        err.statusCode = 500
        err.template =
            name: 'error'
            params: polyglot: localization.getPolyglot()
        errorHandler err, req, res

    # Manage socket.io's websocket
    server.on 'upgrade', (req, socket, head) ->
        # Dirty trick to authenticate websockets
        req.originalUrl = req.url
        fakeRes = on: ->
        [cookieParser, sessionParser, initialize, session] = config.authSteps
        async.series [
            (callback) -> cookieParser req, fakeRes, callback
            (callback) -> sessionParser req, fakeRes, callback
            (callback) -> initialize req, fakeRes, callback
            (callback) -> session req, fakeRes, callback
        ], (err) ->
            # public routes shouldn't be authenticated
            isPublic = /^\/public\/(.*)/.test req.url
            if (req.isAuthenticated() and not err) or isPublic
                #console.log app._router.matchRequest.toString()
                # this can break at any express upgrade
                if slug = app._router.matchRequest(req).params.name
                    if /^\/apps\/(.*)/.test req.url
                        req.url = req.url.replace "/apps/#{slug}", ''
                    else if isPublic
                        req.url = req.url.replace "/public/#{slug}", '/public'

                    routes = router.getRoutes()
                    port = routes[slug].port
                else
                    port = process.env.DEFAULT_REDIRECT_PORT

                proxy.ws req, socket, head,
                    target: "ws://localhost:#{port}"
                    ws: true
            else
                logger.error err if err?
                logger.error "Socket unauthorized"

