fs = require("fs")
should = require('chai').Should()
async = require('async')

helpers = require './helpers'
passwordKeys = require "#{helpers.prefix}server/lib/password_keys"

describe "Password Keys", ->

    before helpers.deleteAllUsers
    before helpers.createUser "user@CozyCloud.CC", "user_pwd"
    after helpers.deleteAllUsers

    describe "Initialize keys", ->

        it "When I initialize keys", (done) ->
            passwordKeys.initializeKeys "password", (err) =>
                @err = err
                done()

        it "Then no error is returned", ->
            should.not.exist @err

    describe "Update keys", ->

        it "When I update keys", (done) ->
            passwordKeys.updateKeys "newPassword", (err) =>
                @err = err
                done()

        it "Then no error is returned", ->
            should.not.exist @err

    describe "Initialize keys in a second connexion", ->

        it "When I initialize keys", (done) ->
            passwordKeys.initializeKeys "newPassword", (err) =>
                @err = err
                done()

        it "Then no error is returned", ->
            should.not.exist @err
