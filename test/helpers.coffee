http = require('http')
module.exports = helpers = {}
UserManager = require('../models').UserManager

helpers.createUserAllRequest = (done) ->
    @timeout 5000
    @userManager ?= new UserManager()
    map = (doc) -> emit doc._id, doc if doc.docType is "User"
    design_doc = map: map.toString()
    @userManager.dbClient.put 'request/user/all/', design_doc, done

helpers.deleteAllUsers = (done) ->
    @timeout 5000
    @userManager ?= new UserManager()
    @userManager.dbClient.put 'request/user/all/destroy/', {}, done

helpers.patchCookieJar = ->
    # https://gist.github.com/jfromaniello/4087861
    # use request cookiejar with socket.io-client
    originalXHR = require('xmlhttprequest').XMLHttpRequest
    xhrPackage = 'socket.io-client/node_modules/xmlhttprequest'
    request = require 'request-json/node_modules/request'
    @jar = jar = request.jar()

    require(xhrPackage).XMLHttpRequest = ->
        originalXHR.apply @, arguments
        @setDisableHeaderCheck true
        stdOpen = @open

        @open = ->
            stdOpen.apply @, arguments
            header = jar.get url: 'http://localhost:4444'
            header = header.map (c) -> c.name + "=" + c.value
            header = header.join "; "
            @setRequestHeader 'cookie', header
        @

helpers.login = (httpClient, pass) -> (done) ->
    Cookie = require 'request-json/node_modules/request/vendor/cookie'
    httpClient.post 'login', password: pass, (err, res) =>
        cookie = res.headers["set-cookie"][0]
        @jar.add(new Cookie(cookie))
        done()

helpers.createUser = (email, pass) -> (done) ->
    {cryptPassword} = require '../helpers'
    user =
        email: email
        owner: true
        password: cryptPassword(pass).hash
        activated: true

    @userManager.create user, done


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