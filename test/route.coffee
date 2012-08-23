should = require('chai').Should()
{Client} = require '../common/test/client'
{CozyProxy} = require "../router.coffee"
http = require('http')

client = new Client("http://localhost:4444/")
router = new CozyProxy()

describe "/routes", ->

    before ->
        router.start 4444
        router.routes["/apps/app1"] = 8001
        router.routes["/apps/app2"] = 8002
        router.routes["/apps/app3"] = 8003

    after ->
        router.stop()

    describe "GET /routes Return available routes.", ->

        it "When I request for routes", (done) ->
            client.get "routes/", (error, response, body) =>
                response.statusCode.should.equal 200
                @body = JSON.parse body
                done()

        it "Then I got 3 routes", ->
            nbRoutes = 0
            nbRoutes++ for route of @body
            nbRoutes.should.equal 3
        

    describe "POST /routes Add route", ->
            
        it "When I send a new route", (done) ->
            @route = "/apps/myapp"
            data = route: @route, port: 8100
            client.post "routes/add", data, (error, response, body) =>
                response.statusCode.should.equal 201
                done()

        it "Then I got my route set inside router", ->
            should.exist router.routes[@route]
            router.routes[@route].should.equal 8100


    describe "PUT /routes Del route", ->
            
        it "When I delete a route", (done) ->
            @route = "/apps/myapp"
            data = route: @route
            client.put "routes/del", data, (error, response, body) =>
                response.statusCode.should.equal 204
                done()

        it "Then I got my route set inside router", ->
            should.not.exist router.routes[@route]


describe "Proxying", ->

    before ->
        router.start 4444
        router.routes["/apps/myapp"] = 4445
        @server = http.createServer (req, res) ->
          res.writeHead 200, 'Content-Type': 'application/json'
          res.end(JSON.stringify msg:"ok")
        @server.listen(4445, 'localhost')

    after ->
        router.stop()
        @server.close

    describe "Proxy success", ->
        it "When I send a request to an existing route", (done) ->
            client.get "apps/myapp", (error, response, body) =>
                response.statusCode.should.equal 200
                @body = JSON.parse body
                done()

        it "Then I got a response from target server", ->
            should.exist @body.msg
            @body.msg.should.equal "ok"

matchRoute = (route) ->
    req = url: route
    res = null
    router._matchRoute req, router.routes, (route) ->
        res = router.routes[route]
    res

describe "Route matching", ->

    before ->
        router.routes = {}
        router.routes["/apps/app1/"] = 8001
        router.routes["/apps/app2/"] = 8002
        router.routes["/apps/app3/"] = 8003
        router.routes["/apps/app/"] = 8004

    it "When I claim for the port of /app/app1/", ->
        @port = matchRoute "/apps/app1/"

    it "Then I got port 8001", ->
        @port.should.equal 8001

    it "When I claim for the port of /app/app/", ->
        @port = matchRoute "/apps/app/"

    it "Then I got port 8004", ->
        @port.should.equal 8004

    it "When I claim for the port of /app/app/", ->
        @port = matchRoute "/apps/apparezre/"

    it "Then I got port 8004", ->
        @port?.should.not.ok

    it "When I claim for the port of /app/app/", ->
        @port = matchRoute "/apps/app/test/blabla/app"

    it "Then I got port 8004", ->
        @port.should.equal 8004
