http = require 'http'
ioClient = require 'socket.io-client'
ioServer = require 'socket.io'
Client = require('request-json').JsonClient
httpClient = new Client("http://localhost:4444/")

{cryptPassword} = require '../helpers'
UserManager = require('../models').UserManager
helpers = require './helpers'

{CozyProxy} = require '../proxy.coffee'
router = new CozyProxy()


describe "websockets", ->

    before helpers.createUserAllRequest
    before helpers.deleteAllUsers
    before helpers.patchCookieJar
    before helpers.createUser "test@cozycloud.cc", 'password'

    before helpers.fakeServer 'myapp', 4445, msg: 'ok', (app) ->
        app.sockets = ioServer.listen app
        app.sockets.set 'log level', 0
        app.sockets.on 'connection', (client) ->
            client.emit 'welcome'

    before ->
        router.start 4444
        router.routes["myapp"] = port: 4445, state: 'installed'

    after ->
        router.stop()
        router.routes = {}
        @fakeServers['myapp'].close()

    after  helpers.deleteAllUsers

    describe "When I request without a cookie", ->

        it "should refuse the request", (done) ->
            client = ioClient.connect 'http://localhost',
                'force new connection':true
                port:4444
                resource: 'apps/myapp/socket.io'
                transports: ['websocket']

            client.on 'error', ->
                done()

    describe "When I request with a cookie", ->

        before helpers.login httpClient, 'password'

        it "should forward to the application", (done) ->
            @timeout 5000
            client = ioClient.connect 'http://localhost',
                'force new connection': true
                port: 4444
                resource: 'apps/myapp/socket.io'
                transports: ['websocket']

            client.on 'connect', ->

            client.on 'error', ->
                done new Error('client error')

            client.on 'welcome', ->
                client.disconnect()

            client.on 'disconnect', ->
                done()
