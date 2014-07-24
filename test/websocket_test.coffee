should = require('chai').Should()
ioClient = require 'socket.io-client'
ioServer = require 'socket.io'

helpers = require './helpers'
router = require "#{helpers.prefix}server/lib/router"

describe "websockets", ->

    before helpers.deleteAllUsers
    before helpers.patchCookieJar
    before helpers.createUser "test@cozycloud.cc", 'password'

    before helpers.fakeServer 'home', 4446, msg: 'ok', (app) ->
        app.sockets = ioServer.listen app
        app.sockets.set 'log level', 0
        app.sockets.on 'connection', (client) ->
            client.emit 'welcomehome'

    before helpers.fakeServer 'myapp', 4445, msg: 'ok', (app) ->
        app.sockets = ioServer.listen app
        app.sockets.set 'log level', 0
        app.sockets.on 'connection', (client) ->
            client.emit 'welcome'

    before helpers.fakeServer 'myapp2', 4447, msg: 'ok', (app) ->
        app.psockets = ioServer.listen app, resource: '/public/socket.io'
        app.psockets.set 'log level', 0
        app.psockets.on 'connection', (client) ->
            client.emit 'welcomepublic'

    before helpers.startApp
    before ->
        router.routes =
            "myapp": port: 4445, state: 'installed'
            "myapp2": port: 4447, state: 'installed'

    after helpers.stopApp
    after -> @fakeServers['home'].close()
    after -> @fakeServers['myapp'].close()
    after -> @fakeServers['myapp2'].close()
    after  helpers.deleteAllUsers

    describe "When I request without a cookie", ->

        it "should refuse the request", (done) ->
            client = ioClient.connect 'http://localhost',
                'force new connection': true
                port: helpers.options.serverPort
                resource: 'apps/myapp/socket.io'
                transports: ['websocket']

            client.on 'error', ->
                done()

    describe "When I request without a cookie (public) ", ->

        it "should forward to the application", (done) ->
            client = ioClient.connect 'http://localhost',
                'force new connection': true
                port: helpers.options.serverPort
                resource: 'public/myapp2/socket.io'
                transports: ['websocket']

            client.on 'connect', ->

            client.on 'error', (err) ->
                done new Error "client error -- #{err}"

            client.on 'welcomepublic', ->
                client.disconnect()

            client.on 'disconnect', ->
                done()

    describe "When I request with a cookie", ->

        before helpers.login 'password'
        before helpers.patchSocketIO

        it "should forward to the application", (done) ->
            client = ioClient.connect 'http://localhost',
                'force new connection': true
                port: helpers.options.serverPort
                resource: 'apps/myapp/socket.io'
                transports: ['websocket']

            client.on 'connect', ->

            client.on 'error', (err) ->
                done new Error "client error -- #{err}"

            client.on 'welcome', ->
                client.disconnect()

            client.on 'disconnect', ->
                done()

    describe "When I request the home (with a cookie)", ->

        before helpers.login 'password'
        before helpers.patchSocketIO

        it "should forward to the application", (done) ->
            client = ioClient.connect 'http://localhost',
                'force new connection': true
                port: helpers.options.serverPort
                transports: ['websocket']

            client.on 'connect', ->

            client.on 'error', (err) ->
                done new Error "client error -- #{err}"

            client.on 'welcomehome', ->
                client.disconnect()

            client.on 'disconnect', ->
                done()
