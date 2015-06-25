fs = require("fs")
should = require('chai').Should()
async = require('async')

helpers = require './helpers'
passwordKeys = require "#{helpers.prefix}server/lib/password_keys"
client = helpers.getClient()

describe "Disk space", ->

    before helpers.deleteAllUsers
    before helpers.startApp
    before helpers.createUser "user@CozyCloud.CC", "user_pwd"
    after  helpers.stopApp
    after helpers.deleteAllUsers

    describe "Recover disk space", =>

        describe "Unauthorized request", =>

            it "When I initialize keys", (done) ->
                passwordKeys.initializeKeys "password", (err) =>
                    @err = err
                    done()

            it "And I add a device", (done) =>
                client.setBasicAuth 'owner', 'user_pwd'
                client.post "device/", login:"device", (err,res, body) =>
                    @pwd = body.password
                    @id = body.id
                    done()

            it "And I recover disk space", (done) =>
                client.get "disk-space", (err, res, body) =>
                    @body = body
                    @res = res
                    @err = err
                    done()

            it "Then error is returned", =>
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

            it "Then error is returned", =>
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

