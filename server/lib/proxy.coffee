http = require 'http'
# This requirement monkey patch the fs standard lib. That way it manages better
# the fact that too many file descriptors are opened. It stops creating them
# and create a waiting queue when the number of fd reaches the limit set by the
# kernel.
httpProxy = require 'http-proxy'
logger = require('printit')
    date: false
    prefix: 'lib:proxy'

initializeWebsocketProxy = require './websocket'
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

    initializeWebsocketProxy server, proxy
