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
urlHelper = require 'cozy-url-sdk'
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
        logger.error "Error connecting to #{req.url}"
        logger.error err
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

            proxyWS = (host, port) ->
                proxy.ws req, socket, head,
                    target: "ws://#{host}:#{port}"
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

            urlHelperSlug = slug.replace 'data-system', 'dataSystem'
            host = 'localhost'
            port = routes[slug]?.port

            if urlHelper[urlHelperSlug]
                host = urlHelper[urlHelperSlug].host()
                port = urlHelper[urlHelperSlug].port()

            # /public/XXXXXX
            if publicOrPrivate is 'public'
                req.url = req.url.replace "/public/#{slug}", '/public'
                proxyWS host, port

            # (AUTH) /apps/XXXXX
            else if publicOrPrivate is 'apps' and req.isAuthenticated()
                req.url = req.url.replace "/apps/#{slug}", ''
                proxyWS host, port

            # (AUTH) /XXXXX -> HOME
            else if req.isAuthenticated()
                proxyWS urlHelper.home.host(), urlHelper.home.port()

            else
                fail new Error 'socket not authorized'
