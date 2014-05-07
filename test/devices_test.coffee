fs = require("fs")
should = require('chai').Should()
async = require('async')

helpers = require './helpers'
client = helpers.getClient()

describe "Devices", =>

    #before helpers.deleteAllUsers
    before helpers.startApp
    before helpers.createUser "user@CozyCloud.CC", "user_pwd"
    after  helpers.stopApp
    after helpers.deleteAllUsers

    describe "Add device", =>

        describe 'Unauthorized request', ->

            it "When I send a request without authentication", (done) ->
                client.post "device/", login:"test", (err,res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then unauthorized error is returned", ->
                should.exist @body.error
                @res.statusCode.should.equal 401
                @body.error.should.equal 'Bad credentials'

        describe 'Authorized request', =>

            it "When I send a request with authentication", (done) =>
                client.setBasicAuth 'owner', 'user_pwd' 
                client.post "device/", login:"test_device", (err,res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    @id = body.id
                    done()

            it "Then 200 is return as status code", =>
                should.not.exist @body.error
                @res.statusCode.should.equal 200


    describe "Remove device", =>

        describe 'Unauthorized request', ->

            it "When I send a request without authentication", (done) ->
                client.setBasicAuth '', '' 
                client.del "device/{@id}/", (err,res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then unauthorized error is returned", ->
                should.exist @body.error
                @res.statusCode.should.equal 401
                @body.error.should.equal 'Bad credentials'

        describe 'Authorized request', =>

            it "When I send a request with authentication", (done) =>
                client.setBasicAuth 'owner', 'user_pwd' 
                client.del "device/#{@id}/", (err,res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then 200 is return as status code", =>
                should.not.exist @body.error
                @res.statusCode.should.equal 200



