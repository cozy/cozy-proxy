http = require 'http'
# This requirement monkey patch the fs standard lib. That way it manages better
# the fact that too many file descriptors are opened. It stops creating them
# and create a waiting queue when the number of fd reaches the limit set by the
# kernel.
fs = require 'graceful-fs'
httpProxy = require 'http-proxy'
async = require 'async'
passport = require 'passport'
config = require '../config'
logger = require('printit')
    date: false
    prefix: 'lib:proxy'

router = require './router'
errorHandler = require '../middlewares/errors'

# singleton variable
proxy = null

module.exports.getProxy = -> return proxy

module.exports.initializeProxy = (app, server) ->

    # create proxy server
    proxy = httpProxy.createProxyServer
        agent: new http.Agent()

    # proxy error handling
    proxy.on 'error', (err, req, res) ->
        if /ECONNREFUSED/.test err
            console.log "connexion to #{req.url} refused"
        else
            console.log err

        err = new Error err
        err.statusCode = 500
        err.template =
            name: 'error'
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

            proxyWS = (port) ->
                proxy.ws req, socket, head,
                    target: "ws://localhost:#{port}"
                    ws: true

            fail = (err) ->
                logger.error err if err?
                logger.error "Socket unauthorized"
                socket.end "HTTP/1.1 400 Connection Refused \r\n" +
                "Connection: close\r\n\r\n", 'ascii'

            return fail err if err

            # express doesn't expose its router, we do it manually
            [_, publicOrPrivate, slug] = req.url.split '/'
            routes = router.getRoutes()

            # /public/XXXXXX
            if publicOrPrivate is 'public'
                req.url = req.url.replace "/public/#{slug}", '/public'
                proxyWS routes[slug].port

            # (AUTH) /apps/XXXXX
            else if publicOrPrivate is 'apps' and req.isAuthenticated()
                req.url = req.url.replace "/apps/#{slug}", ''
                proxyWS routes[slug].port

            # (AUTH) /XXXXX -> HOME
            else if req.isAuthenticated()
                proxyWS process.env.DEFAULT_REDIRECT_PORT

            else
                fail new Error('socket not authorized')
