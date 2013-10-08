fs = require("fs")
should = require('chai').Should()
async = require('async')

Client = require("request-json").JsonClient
PasswordKeys = require "../lib/password_keys"

client = new Client "http://localhost:9101/"
passwordKeys = new PasswordKeys()
helpers = require './helpers'


describe "Password Keys", ->

    before helpers.createUserAllRequest
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

    describe "Delete keys", ->

        it "When I delete keys", (done) ->
            passwordKeys.deleteKeys (err) =>
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
