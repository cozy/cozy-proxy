http = require('http')
should = require('chai').Should()
Client = require('request-json').JsonClient

helpers = require '../helpers'
{CozyProxy} = require '../proxy.coffee'
UserManager = require('../models').UserManager

client = new Client("http://localhost:4444/")
router = new CozyProxy()

describe "/routes", ->

    before (done) ->
        router.start 4444
        router.routes["/apps/app1"] = 8001
        router.routes["/apps/app2"] = 8002
        router.routes["/apps/app3"] = 8003
        map = (doc) ->
            emit doc._id, doc if doc.docType is "User"
        design_doc =
            "map": map.toString()
        clientDS = new Client("http://localhost:9101/")
        clientDS.put 'request/user/all/', design_doc, (err, res, body) =>
            done()

    after ->
        router.stop()

    describe "GET /routes Return available routes.", ->

        it "When I request for routes", (done) ->
            client.get "routes/", (error, response, body) =>
                response.statusCode.should.equal 200
                @body = body
                done()

        it "Then I got 3 routes", ->
            nbRoutes = 0
            nbRoutes++ for route of @body
            nbRoutes.should.equal 3

describe "Proxying", ->

    fakeHomeLastUrl = ""

    before (done) ->

        router.defaultPort = 4446
        router.start 4444
        router.routes["myapp"] = {port:4445, state:'installed'}
        router.routes["myapp2"] = {port:4447, state:'stopped'}
        @fakeHome = http.createServer (req, res) ->
            fakeHomeLastUrl = req.url
            res.writeHead 201
            res.end(JSON.stringify {app:{port:4447, state:'installed'}})
        @fakeHome.listen router.defaultPort

        @server = http.createServer (req, res) ->
            res.writeHead 200, 'Content-Type': 'application/json'
            res.end(JSON.stringify msg:"ok")
        @server.listen 4445, 'localhost'

        @server2 = http.createServer (req, res) ->
            res.writeHead 200, 'Content-Type': 'application/json'
            res.end(JSON.stringify msg:"ok2")
        @server2.listen 4447, 'localhost'

        @userManager = new UserManager()

        @userManager.dbClient.setBasicAuth "proxy", "token"
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
        @server.close()
        @server2.close()

    describe "Redirection", ->
        it "When I send non-identified request to an existing
private route", (done) ->
            client.get "apps/myapp/", (error, response, body) =>
                @response = response
                done()

        it "Then I should get redirected to login", ->
            @response.statusCode.should.equal 200
            @response.request.path.should.equal "/login/apps/myapp/"

        it "When I send non-identified request to an existing
private route (with params)", (done) ->
            client.get "apps/myapp/?param=a", (error, response, body) =>
                @response = response
                done()

        it "Then I should get redirected to login", ->
            @response.statusCode.should.equal 200
            @response.request.path.should.equal "/login/apps/myapp/?param=a"


    describe "Public proxying", ->

        it "When I send a request to an existing public route", (done) ->
            client.get "public/myapp/", (error, response, body) =>
                @body = body
                @response = response
                done()

        it "Then I should be proxyed to the app server", ->
            @response.statusCode.should.equal 200
            should.exist @body.msg
            @body.msg.should.equal "ok"

    describe "Private proxying", ->
        it "When I send an authentified request to an existing route", (done)->
            client.post 'login', password: "password", =>
                client.get "apps/myapp/", (error, response, body) =>
                    @response = response
                    @body = body
                    done()

        it "Then I should be redirected to the app server", ->
            @response.statusCode.should.equal 200
            should.exist @body.msg
            @body.msg.should.equal "ok"

    describe "no regression on issue #1", ->
        it "When I send an request to myapp2 ", (done) ->
            client.post 'login', password: "password", =>
                client.get "apps/myapp2/", (error, response, body) =>
                    @response = response
                    @body = body
                    done()

        it "Then I should be redirected to the myapp2
server (and not myapp)", ->
            @response.statusCode.should.equal 200
            should.exist @body.msg
            @body.msg.should.equal "ok2"

    describe "Autostarting", ->

        it "When I send a request to a stopped app", (done) ->
            client.get "apps/myapp2/", (error, response, body) =>
                @body = body
                @response = response
                done()

        it "should have called home to start the app", ->
            fakeHomeLastUrl.should.equal "/api/applications/myapp2/start"

        it "Then I should be proxyed to the app server", ->
            @response.statusCode.should.equal 200
            should.exist @body.msg
            @body.msg.should.equal "ok2"
