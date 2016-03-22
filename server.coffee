fs = require 'fs'
urlHelper = require 'cozy-url-sdk'

process.env.NODE_ENV ?= "development"

process.on 'uncaughtException', (err) ->
    console.error err.message
    console.error err.stack

application = module.exports = (callback) ->

    americano = require 'americano'
    initialize = require './server/initialize'
    errorMiddleware = require './server/middlewares/errors'

    options =
        name: 'proxy'
        port: process.env.PORT or urlHelper.proxy.port()
        host: process.env.HOST or urlHelper.proxy.host()
        root: __dirname

    if process.env.USE_SSL
        crtPath = process.env.SSL_CRT_PATH or '/etc/cozy/server.crt'
        keyPath = process.env.SSL_KEY_PATH or '/etc/cozy/server.key'
        options.tls =
            cert: fs.readFileSync crtPath
            key:  fs.readFileSync keyPath

    americano.start options, (err, app, server) ->
        app.use errorMiddleware
        initialize app, server, callback

if not module.parent
    application()
