should = require('chai').Should()
{Client} = require '../common/test/client'
{CozyProxy} = require "../router.coffee"

client = new Client("http://localhost:4444/")
router = new CozyProxy()


describe "/routes", ->

    before ->
        router.start 4444

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


