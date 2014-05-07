fs = require("fs")
should = require('chai').Should()
async = require('async')

helpers = require './helpers'
client = helpers.getClient()

describe "Disk space", ->

    before helpers.deleteAllUsers
    before helpers.startApp
    before helpers.createUser "user@CozyCloud.CC", "user_pwd"
    after  helpers.stopApp
    after helpers.deleteAllUsers

    describe "Recover disk space", =>

        describe "Unauthorized request", =>

            it "When I send a request with authentication", (done) =>
                client.setBasicAuth 'owner', 'user_pwd' 
                client.post "device/", login:"device", (err,res, body) =>
                    @pwd = body.password
                    @id = body.id
                    setTimeout () =>
                        done()
                    , 500

            it "And I recover disk space", (done) =>
                client.get "disk-space", (err, res, body) =>
                    @body = body
                    @res = res
                    @err = err
                    done()

            it "Then disk space is returned", =>
                should.exist @body.error
                @res.statusCode.should.equal 401

        describe "Bad uthorization request", =>

            it "And I recover disk space", (done) =>
                client.setBasicAuth 'device', "pwd"
                client.get "disk-space", (err, res, body) =>
                    @body = body
                    @res = res
                    @err = err
                    done()

            it "Then disk space is returned", =>
                should.exist @body.error
                @res.statusCode.should.equal 401

        describe "Authorized request", =>

            it "And I recover disk space", (done) =>
                client.setBasicAuth 'device', @pwd 
                client.get "disk-space", (err, res, body) =>
                    @body = body
                    @res = res
                    @err = err
                    done()

            it "Then disk space is returned", =>
                should.not.exist @body.error
                @res.statusCode.should.equal 200
                should.exist @body.diskSpace

    describe 'Remove device', =>

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

