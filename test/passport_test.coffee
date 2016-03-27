should = require('chai').Should()
nock = require 'nock'
helpers = require './helpers'
cozydb = require 'cozydb'

router = require "#{helpers.prefix}server/lib/router"

client = helpers.getClient()

email = "john.doe@cozycloud.cc"
password = "password"
timezone = "Europe/Paris"
public_name = "John"
locale = "fr"

# 2FA constants
otpKey = "7lmt5npm7p"
incorrectOtpToken = "133742"
expectedHotpCounter = 23
hotpToken = "348470"

User = cozydb.getModel 'User',
    authType: String,
    otpKey: String
    hotpCounter: Number


describe "Register / Login", ->

    before helpers.deleteAllUsers
    before helpers.startApp
    after helpers.stopApp
    after helpers.deleteAllUsers

    describe "Register", ->

        it "When I send a request to register", (done) ->
            data =
                email: email
                password: password
                timezone: timezone
                public_name: public_name
                locale: locale
            client.post "register", data, (error, response, body) =>
                @body = body
                @response = response
                done()

        it "Then I got a success response", ->
            @response.statusCode.should.equal 200
            should.exist @body
            @body.success.should.equal true

    describe "Login", ->

        it "When I send a request to login", (done) ->
            client.post "login", password: password, (error, response, body) =>
                @body = body
                @response = response
                done()

        it "Then user is authenticated", (done) ->
            client.get "authenticated", (error, response, body) ->
                response.statusCode.should.equal 200
                body.should.have.property 'isAuthenticated'
                body.isAuthenticated.should.be.ok
                done()

    describe "Login with two-factors authentication: TOTP", ->

        before (done) ->
            # Logging out
            client.get "logout", (error, response, body) ->
                # Adding TOTP setting to the user's settings
                User.request "all", (error, users) ->
                    users[0].updateAttributes
                        authType: "totp",
                        otpKey: otpKey
                    , (error) ->
                        done()

        it "Login requests without OTP get unsuccessful response", (done) ->
            client.post "login",
                password: password
            , (error, response, body) =>
                response.statusCode.should.equal 401
                done()

        it "Login requests with wrong OTP get unsuccessful response", (done) ->
            client.post "login",
                password: password,
                authcode: incorrectOtpToken
            , (error, response, body) =>
                response.statusCode.should.equal 401
                done()

        it "So far, the user is not authenticated", (done) ->
            client.get "authenticated", (error, response, body) ->
                response.statusCode.should.equal 200
                body.should.have.property 'isAuthenticated'
                body.isAuthenticated.should.not.be.ok
                done()

    describe "Login with two-factors authentication: HOTP", ->

        before (done) ->
            # Adding HOTP setting to the user's settings
            User.request "all", (error, users) ->
                users[0].updateAttributes
                    authType: "hotp",
                    hotpCounter: 0
                , (error) ->
                    done()

        after (done) ->
            # Removing the 2FA settings
            User.request "all", (error, users) ->
                users[0].updateAttributes
                    authType: null
                , (error) ->
                    done()

        it "Login requests with no OTP get unsuccessful response", (done) ->
            client.post "login",
                password: password
            , (error, response, body) =>
                response.statusCode.should.equal 401
                done()

        it "Login requests with wrong OTP get unsuccessful response", (done) ->
            client.post "login",
                password: password,
                authcode: incorrectOtpToken
            , (error, response, body) =>
                response.statusCode.should.equal 401
                done()

        it "So far, the user is not authenticated yet", (done) ->
            client.get "authenticated", (error, response, body) ->
                response.statusCode.should.equal 200
                body.should.have.property 'isAuthenticated'
                body.isAuthenticated.should.not.be.ok
                done()

        it "Login requests with correct OTP get successful response", (done) ->
            client.post "login",
                password: password,
                authcode: hotpToken
            , (error, response, body) =>
                response.statusCode.should.equal 200
                done()

        it "Now, the user is authenticated", (done) ->
            client.get "authenticated", (error, response, body) ->
                response.statusCode.should.equal 200
                body.should.have.property 'isAuthenticated'
                body.isAuthenticated.should.be.ok
                done()

        it "After successful auth, the counter is set in base", (done) ->
            User.request "all", (error, users) ->
                users[0].hotpCounter.should.equal expectedHotpCounter
                done()

    describe "Logout", ->

        it "When I send a request to logout", (done) ->
            client.get "logout", (error, response, body) ->
                response.statusCode.should.equal 204
                done()

        it "Then user isn't authenticated anymore", (done) ->
            client.get "authenticated", (error, response, body) ->
                body.should.have.property 'isAuthenticated'
                body.isAuthenticated.should.not.be.ok
                done()

    describe "When I login again", (done) ->

        before helpers.fakeServer 'myapp', 4445, msg: 'ok'
        before -> router.routes = "myapp": port: 4445, state: 'installed'
        before (done) ->
            client.post "login", password: password, (error, response, body) =>
                @body = body
                @response = response
                done()

        after helpers.closeFakeServers

        it "The server should send the cookie", ->
            should.exist @response
            @response.should.have.property 'headers'
            @response['headers'].should.have.property 'set-cookie'

        it "And it shouldn't send the cookie afterwards", (done) ->
            client.get 'apps/myapp', (err, res, body) ->
                should.exist res
                res.should.have.property 'headers'
                res['headers'].should.not.have.property 'set-cookie'
                done()
            , false

describe "Register failure", ->

    before helpers.deleteAllUsers
    before helpers.startApp
    after helpers.stopApp
    after helpers.deleteAllUsers

    it "When I send a register request with a wrong string as email", (done) ->
        data = email: "wrongemail", password: password
        client.post "register", data, (error, response, body) =>
            @response = response
            @body = body
            done()

    it "Then an error response is returned.", ->
        @response.statusCode.should.equal 400
        @body.should.have.property 'error'

    it "When I send a register request with a too short password", (done) ->
        data = email: email, password: "pas"
        client.post "register", data, (error, response, body) =>
            @response = response
            @body = body
            done()

    it "Then an error response is returned.", ->
        @response.statusCode.should.equal 400
