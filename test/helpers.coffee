http = require 'http'
Client = require('request-json').JsonClient
module.exports = helpers = {}
urlHelper = require 'cozy-url-sdk'

if process.env.COVERAGE
    helpers.prefix = '../instrumented/'
else if process.env.USE_JS
    helpers.prefix = '../build/'
else
    helpers.prefix = '../'

# server management
helpers.options =
    serverHost: process.env.HOST or urlHelper.proxy.host()
    serverPort: process.env.PORT or urlHelper.proxy.port()

localization = require "#{helpers.prefix}server/lib/localization_manager"

# default client
client = new Client "#{urlHelper.proxy.schema()}://#{helpers.options.serverHost}:#{helpers.options.serverPort}/", jar: true

# set the configuration for the server
process.env.HOST = helpers.options.serverHost
process.env.PORT = helpers.options.serverPort

# set the HOME PORT
process.env.DEFAULT_REDIRECT_PORT = 4446

# Returns a client if url is given, default app client otherwise
helpers.getClient = (url = null) ->
    if url?
        return new Client url, jar: true
    else
        return client

initializeApplication = require "#{helpers.prefix}server"

helpers.startApp = (done) ->
    @timeout 15000
    initializeApplication (app, server) =>
        @app = app
        @app.server = server
        done()

helpers.stopApp = (done) ->
    @timeout 10000
    setTimeout =>
        @app.server.close done
    , 1000


helpers.patchCookieJar = ->
    # https://gist.github.com/jfromaniello/4087861
    # use request cookiejar with socket.io-client
    originalXHR = require('xmlhttprequest').XMLHttpRequest
    try
        xhrPackage = 'socket.io-client/node_modules/xmlhttprequest'
        request = require 'request-json/node_modules/request'
    catch
        xhrPackage = 'xmlhttprequest'
        request = require 'request'
    @jar = jar = {cookies:[]}

    require(xhrPackage).XMLHttpRequest = ->
        originalXHR.apply @, arguments
        @setDisableHeaderCheck true
        stdOpen = @open

        @open = ->
            stdOpen.apply @, arguments
            @setRequestHeader 'cookie', jar.cookies.join('; ')
        @

helpers.patchSocketIO = ->
    jar = @jar
    WS = require('socket.io-client/lib/transports/websocket').websocket
    ioutil = require('socket.io-client/lib/util').util

    WS.prototype.open = ->
        query = ioutil.query this.socket.options.query
        self = this

        try
            Socket = require 'socket.io-client/node_modules/ws'
        catch
            Socket = require 'ws'

        unless Socket
            Socket = global.MozWebSocket or global.WebSocket

        url = @prepareUrl() + query
        @websocket = new Socket url, headers: 'Cookie': jar.cookies.join('; ')

        @websocket.onopen = ->
            self.onOpen()
            self.socket.setBuffer false

        @websocket.onmessage = (ev) -> self.onData ev.data

        @websocket.onclose = ->
            self.onClose()
            self.socket.setBuffer true

        @websocket.onerror = (e) -> self.onError e

      return @

helpers.login = (password) -> (done) ->
    client = helpers.getClient()
    client.post 'login', password: password, (err, res) =>
        if res.headers['set-cookie']
            @jar.cookies = res.headers["set-cookie"].map (cookie) ->
                cookie.split(';')[0]
        done()

helpers.createAllRequests = (done) ->
    @timeout 15000
    root = require('path').join __dirname, '..'
    require('americano').configure root, null, (err) ->
        done err

User = require "#{helpers.prefix}server/models/user"

helpers.createUser = (email, pass) -> (done) ->
    {cryptPassword} = require "#{helpers.prefix}server/lib/helpers"
    user =
        email: email
        password: cryptPassword(pass).hash
        owner: true
        activated: true
    User.createNew user, done

helpers.deleteAllUsers = (done) ->
    @timeout 5000
    User.requestDestroy 'all', done

helpers.fakeServer = (name, port, json, prepare) -> (done) ->
    @fakeServers ?= {}
    @fakeServers[name] = http.createServer (req, res) =>
        @fakeServers[name].lastUrl = req.url
        res.writeHead 200, 'Content-Type': 'application/json'
        res.end JSON.stringify json
    prepare? @fakeServers[name]
    @fakeServers[name].listen port, done

helpers.closeFakeServers = ->
    for name, server of @fakeServers
        server.close()
    @fakeServers = {}

helpers.setDefaultLocale = ->
    localization.setLocale 'en'
