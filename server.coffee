process.env.NODE_ENV ?= "development"

process.on 'uncaughtException', (err) ->
    console.error err.message
    console.error err.stack

# default value for the default port (home)
process.env.DEFAULT_REDIRECT_PORT ?= 9103

process.env.DATASYSTEM_HOST ?= 'localhost'
process.env.DATASYSTEM_PORT ?= '9101'
process.env.DATASYSTEM_URL = "http://#{process.env.DATASYSTEM_HOST}:#{process.env.DATASYSTEM_PORT}"

process.env.HOME_HOST ?= 'localhost'
process.env.HOME_PORT ?= process.env.DEFAULT_REDIRECT_PORT
process.env.HOME_URL = "http://#{process.env.HOME_HOST}:#{process.env.HOME_PORT}"

process.env.COUCH_HOST ?= 'localhost'
process.env.COUCH_PORT ?= '5984'
process.env.COUCH_URL = "http://#{process.env.COUCH_HOST}:#{process.env.COUCH_PORT}"


application = module.exports = (callback) ->

    americano = require 'americano'
    initialize = require './server/initialize'
    errorMiddleware = require './server/middlewares/errors'

    options =
        name: 'proxy'
        port: process.env.PORT or 9104
        host: process.env.HOST or "127.0.0.1"
        root: __dirname

    americano.start options, (app, server) ->
        app.use errorMiddleware
        initialize app, server, callback

if not module.parent
    application()