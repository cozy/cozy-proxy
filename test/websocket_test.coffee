http = require 'http'
ioClient = require 'socket.io-client'
ioServer = require 'socket.io'
Client = require('request-json').JsonClient
httpClient = new Client("http://localhost:4444/")

helpers = require '../helpers'
UserManager = require('../models').UserManager

Cookie = require 'request-json/node_modules/request/vendor/cookie'
{CozyProxy} = require '../proxy.coffee'
router = new CozyProxy()


# https://gist.github.com/jfromaniello/4087861
patchCookieJar = ->

  xhrPackage = 'socket.io-client/node_modules/xmlhttprequest'
  xhrPackageNew = 'xmlhttprequest' 

  request = require 'request-json/node_modules/request'
  jar = request.jar()

  originalRequest = require(xhrPackageNew).XMLHttpRequest

  require(xhrPackage).XMLHttpRequest = ->
      originalRequest.apply @, arguments
      @setDisableHeaderCheck true
      stdOpen = @open
     
      @open = ->
          stdOpen.apply @, arguments
          header = jar.get url: 'http://localhost:4444'
          header = header.map (c) -> c.name + "=" + c.value
          header = header.join "; "
          @setRequestHeader 'cookie', header
      @

  jar


describe "websockets", ->

    before (done) ->

        @jar = patchCookieJar()

        router.start 4444
        router.routes["myapp"] = 4445
        @myapp = http.createServer (req, res) ->
            res.writeHead 200, 'Content-Type': 'application/json'
            res.end(JSON.stringify msg:"ok")
        @myapp.sockets = ioServer.listen @myapp
        @myapp.sockets.on 'connection', (client) ->
            client.emit 'welcome'

        @myapp.listen 4445, 'localhost'

        @userManager = new UserManager()

        @userManager.dbClient.put 'request/user/all/destroy/', {}, (err) =>
            password = helpers.cryptPassword('password').hash
            user =
                email: "test@cozycloud.cc"
                owner: true
                password: password
                activated: true

            @userManager.create user, (err, code, user) =>
                done()

    after ->
        router.stop()
        @myapp.sockets.server.close()

    describe "When I open a socket.io connection to the proxy", ->

        it "It get redirected to the correct app", (done) ->
          httpClient.post 'login', password: "password", (err, res) =>
            cookie = res.headers["set-cookie"][0];
            @jar.add(new Cookie(cookie))

            client = ioClient.connect 'http://localhost', 
              port:4444
              resource: 'apps/myapp/socket.io'
              transports: ['websocket']

            client.on 'connect', ->
              console.log 'connected'
            client.on 'welcome', ->
              client.disconnect()
            client.on 'disconnect', ->
              done()


