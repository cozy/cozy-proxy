fs = require("fs")
should = require('chai').Should()
async = require('async')

Client = require("request-json").JsonClient
PasswordKeys = require "../lib/password_keys"

client = new Client "http://localhost:9101/"
passwordKeys = new PasswordKeys()


describe "Password Keys", ->
    describe "Initialize keys", ->

        before (done) ->
            @timeout 5000
            client.setBasicAuth "proxy", "token"
            client.del 'data/102/', (err, res, body) =>
                data =
                    email: "user@CozyCloud.CC"
                    timezone: "Europe/Paris"
                    password: "user_pwd"
                    docType: "User"
                client.post 'data/102/', data, (err, res, body) =>
                    pwd = password: "password"
                    client.post "accounts/password/", pwd, (err, res, body) =>
                        done()


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
