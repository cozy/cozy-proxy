should = require('chai').Should()
nock = require 'nock'
helpers = require './helpers'
urlHelper = require 'cozy-url-sdk'

client = helpers.getClient()

router = require "#{helpers.prefix}server/lib/router"

describe "/routes", ->

    before helpers.deleteAllUsers

    before helpers.startApp
    before ->
        router.routes =
            "app1": port: 4441, state: 'installed'
            "app2": port: 4442, state: 'installed'
            "app3": port: 8003, state: 'installed'
    after  helpers.stopApp
    after  helpers.deleteAllUsers

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

    before helpers.deleteAllUsers
    before helpers.createUser 'test@cozycloud.cc', 'password'

    homeResponse = app: port: 4447, state: 'installed'
    before helpers.fakeServer 'home', 4446, homeResponse
    before helpers.fakeServer 'myapp', 4445, msg: 'ok'
    before helpers.fakeServer 'myapp2', 4447, msg: 'ok2'

    before helpers.startApp
    before ->
        router.routes =
            "myapp": port: 4445, state: 'installed'
            "myapp2": port: 4447, state: 'stopped'
            "front": type: 'static',
            state: 'installed',
            path: '/usr/local/cozy/apps/front'

    after helpers.stopApp
    after helpers.closeFakeServers

    describe "Redirection", ->
        it "When I send non-identified request to an existing private route", \
        (done) ->
            @timeout 10000
            client.get "apps/myapp/", (error, response, body) =>
                @response = response
                done()

        it "Then I should get redirected to login", ->
            @response.statusCode.should.equal 200
            uri = "/login?next="
            params = "/apps/myapp/"
            @response.request.path.should.equal uri + encodeURIComponent(params)

        it "When I send non-identified request to an existing
private route (with params)", (done) ->
            client.get "apps/myapp/?param=a", (error, response, body) =>
                @response = response
                done()

        it "Then I should get redirected to login", ->
            @response.statusCode.should.equal 200
            uri = "/login?next="
            params = "/apps/myapp/?param=a"
            @response.request.path.should.equal uri + encodeURIComponent(params)


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

        before (done) ->
            client.post 'login', password: "password", done

        it "When I send an authentified request to an existing route", (done)->
            client.get "apps/myapp/", (error, response, body) =>
                @response = response
                @body = body
                done()

        it "Then I should be redirected to the app server", ->
            @response.statusCode.should.equal 200
            should.exist @body.msg
            @body.msg.should.equal "ok"

    describe "Autostarting", ->
        before ->
            @scope = nock urlHelper.home.url(), allowUnmocked: true
               .post '/api/applications/myapp2/start'
               .reply 200, {app: port: 4447, state: 'installed'}

        after -> nock.restore()

        it "When I send a request to a stopped app", (done) ->
            client.get "apps/myapp2/", (error, response, body) =>
                @body = body
                @response = response
                done()

        it "should have called home to start the app", ->
            expected = "/api/applications/myapp2/start"
            @scope.isDone().should.be.true

        it "Then I should be proxyed to the app server", ->
            @response.statusCode.should.equal 200
            should.exist @body.msg
            @body.msg.should.equal "ok2"

    describe "no regression on issue #1", ->

        it "When I send an request to myapp2 ", (done) ->
            client.get "apps/myapp2/", (error, response, body) =>
                @response = response
                @body = body
                done()

        it "Then I should be redirected to the myapp2 server (and not myapp)", \
        ->
            @response.statusCode.should.equal 200
            should.exist @body.msg
            @body.msg.should.equal "ok2"

    describe "start static app", ->

        it "When I send a request to front ", (done) ->
            client.get "apps/front/", (error, response, body) =>
                @response = response
                @body = body
                done()
