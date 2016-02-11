fs = require 'fs'

process.env.NODE_ENV ?= "development"

process.on 'uncaughtException', (err) ->
    console.error err.message
    console.error err.stack

# default value for the default port (home)
unless process.env.DEFAULT_REDIRECT_PORT
    process.env.DEFAULT_REDIRECT_PORT = 9103

application = module.exports = (callback) ->

    americano = require 'americano'
    initialize = require './server/initialize'
    errorMiddleware = require './server/middlewares/errors'

    options =
        name: 'proxy'
        port: process.env.PORT or 9104
        host: process.env.HOST or "127.0.0.1"
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
