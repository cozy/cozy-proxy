fs = require "fs"
should = require('chai').Should()
async = require 'async'
urlHelper = require 'cozy-url-sdk'

helpers = require './helpers'
client = helpers.getClient()
Client = require('request-json').JsonClient
clientDS = new Client urlHelper.dataSystem.url()

describe "Devices", ->

    #before helpers.deleteAllUsers
    before helpers.startApp
    before helpers.createUser "user@CozyCloud.CC", "user_pwd"
    after  helpers.stopApp
    after helpers.deleteAllUsers

    devicePassword = null

    describe "Add device", =>

        describe 'Unauthorized request', ->

            it "When I send a request without authentication", (done) ->
                client.post "device", login: "test", (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then unauthorized error is returned", ->
                should.exist @body.error
                @res.statusCode.should.equal 401
                @body.error.should.equal 'Bad credentials'

        describe 'Authorized request', ->

            it "When I send a request with authentication", (done) ->
                client.setBasicAuth 'owner', 'user_pwd'
                client.post "device", login: "test_device", (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    @id = body.id
                    done()

            it "Then 201 is return as status code", ->
                should.not.exist @body.error
                @res.statusCode.should.equal 201

        describe 'Create device with specific permissions', ->

            it "When I send a request with authentication", (done) ->
                client.setBasicAuth 'owner', 'user_pwd'
                device =
                    login: "test_device_2"
                    permissions:
                        'contact': "test"
                client.post "device", device, (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    devicePassword = @body.password
                    @id = body.id
                    done()

            it "Then 201 is return as status code", ->
                should.not.exist @body.error
                @res.statusCode.should.equal 201

            it "And device has access to its permissions", (done) ->
                clientDS.setBasicAuth 'test_device_2', devicePassword
                data =
                    docType: 'contact'
                    slug: 'blabla'
                clientDS.post 'data/', data, (err, res, body) =>
                    @err = err
                    @res = res
                    done()

            it "And 201 is return as status code", ->
                should.not.exist @body.error
                @res.statusCode.should.equal 201

            it "And device hasn't access to its permissions", (done) ->
                clientDS.setBasicAuth 'test_device_2', devicePassword
                data =
                    docType: 'test'
                    slug: 'blabla'
                clientDS.post 'data/', data, (err, res, body) =>
                    @err = err
                    @res = res
                    done()

            it "And 403 is return as status code", ->
                should.not.exist @body.error
                @res.statusCode.should.equal 403

        describe 'Create device with name already used', =>

            it "When I send a request with authentication", (done) =>
                client.setBasicAuth 'owner', 'user_pwd'
                device =
                    login: "test_device_2"
                    permissions:
                        'contact': "test"
                client.post "device", device, (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    @id = body.id
                    client.post "device", device, (err, res, body) =>
                        @err = err
                        @res = res
                        @body = body
                        @id = body.id
                        done()

            it "return an error", =>
                should.exist @body.error
                @body.error.should.equal 'This name is already used'

    describe "Update device", =>

        describe 'Unauthorized request', ->

            it "When I send a request without authentication", (done) ->
                client.setBasicAuth '', ''
                client.put "device/test-device", login: 'test_device', (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then unauthorized error is returned", ->
                should.exist @body.error
                @res.statusCode.should.equal 401
                @body.error.should.equal 'Bad credentials'

        describe 'Modify an uncorrect device', =>

            it "Try to modify a uncorrect device", (done) =>
                client.setBasicAuth 'owner', 'user_pwd'
                client.put "device/device", login: 'device', (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then error is returned", =>
                should.exist @body.error
                @res.statusCode.should.equal 400
                @body.error.should.equal "This device doesn't exist"


        describe 'Modify a correct device', =>

            it "Try to modify a correct device", (done) =>
                client.setBasicAuth 'owner', 'user_pwd'
                device =
                    login: "test_device_2"
                    permissions:
                        'event': "test"
                client.put "device/#{device.login}", device, (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then 200 is return as status code", =>
                should.not.exist @body.error
                @res.statusCode.should.equal 200


    describe "Remove device", ->

        describe 'Unauthorized request', ->

            it "When I send a request without authentication", (done) ->
                client.setBasicAuth '', ''
                client.del "device/test-device", (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then unauthorized error is returned", ->
                should.exist @body.error
                @res.statusCode.should.equal 401
                @body.error.should.equal 'Bad credentials'

        describe 'Delete a device', ->

            it "can't delete a device from another device login", (done) ->
                @timeout 10 * 1000
                client.setBasicAuth  'test_device_2', devicePassword
                client.del "device/test_device", (err, res, body) ->
                    should.exist body.error
                    res.statusCode.should.equal 401
                    body.error.should.equal 'Bad credentials'
                    done()


            it "Delete a device from owner login", (done) ->
                @timeout 10 * 1000
                client.setBasicAuth 'owner', 'user_pwd'
                client.del "device/test_device", (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then 204 is returned as status code", ->
                should.not.exist @body.error
                @res.statusCode.should.equal 204

            it "Delete a device from device login", (done) ->
                @timeout 10 * 1000
                client.setBasicAuth 'test_device_2', devicePassword
                client.del "device/test_device_2", (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then 204 is returned as status code", ->
                should.not.exist @body.error
                @res.statusCode.should.equal 204
