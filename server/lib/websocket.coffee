async = require 'async'
logger = require('printit')
    date: false
    prefix: 'lib:websockets'

config = require '../config'
urlHelper = require 'cozy-url-sdk'
router = require './router'
http = require 'http'
{checkDeviceAuth} = require '../controllers/devices'
socketio = require 'socket.io'
axon = require 'axon'

doProxyWS = (proxy, req, socket, head, host, port) ->
    proxy.ws req, socket, head,
        target: "ws://#{host}:#{port}"
        ws: true

closeWS = (socket, err) ->
    logger.error err if err?
    logger.error "Socket unauthorized"
    socket.end "HTTP/1.1 400 Connection Refused \r\n" +
        "Connection: close\r\n\r\n", 'ascii'

# This is equivalent to having this request pass through
# express cookie authentication flow.
# It seems hacky, maybe there is a better way.
applyCookieAuthMiddlewares = (req, callback) ->
    req.originalUrl = req.url
    fakeRes = on: ->
    applyMiddleware = (middleware, next) ->
        middleware req, fakeRes, next

    async.mapSeries config.authSteps, applyMiddleware, callback

module.exports = (server, proxy) ->

    # Bind socket.io on a useless HTTP server
    sioserver = socketio(new http.Server(->))

    # start axon's socket
    axonsocket = axon.socket 'sub-emitter'
    axonsocket.connect 9105

    # Forward all events to socket.io
    # to @TODO may be we should filter by permissions
    axonsocket.on '*', (event, id) -> sioserver.emit event, id

    server.on 'upgrade', (req, socket, head) ->
        applyCookieAuthMiddlewares req, (err) ->
            return closeWS socket, err if err

            # express doesn't expose its router, we do it manually
            [_, publicOrPrivate, slug] = req.url.split '/'
            routes = router.getRoutes()

            urlHelperSlug = slug.replace 'data-system', 'dataSystem'
            host = 'localhost'
            port = routes[slug]?.port

            if urlHelper[urlHelperSlug]
                host = urlHelper[urlHelperSlug].host()
                port = urlHelper[urlHelperSlug].port()

            # DS API socket
            if req.url is '/ds-api/socket.io'
                checkDeviceAuth req, (auth) ->
                    if auth
                        sioserver.eio.handleUpgrade req, socket, head
                    else
                        closeWS socket, new Error('socket not authenticated')

            # /public/XXXXXX
            else if publicOrPrivate is 'public'
                req.url = req.url.replace "/public/#{slug}", '/public'
                doProxyWS proxy, req, socket, head, host, port

            # (AUTH) /apps/XXXXX
            else if publicOrPrivate is 'apps' and req.isAuthenticated()
                req.url = req.url.replace "/apps/#{slug}", ''
                doProxyWS proxy, req, socket, head, host, port

            # (AUTH) /XXXXX -> HOME
            else if req.isAuthenticated()
                host = urlHelper.home.host()
                port = urlHelper.home.port()
                doProxyWS proxy, req, socket, head, host, port

            else
                closeWS socket, new Error('socket not authorized')
