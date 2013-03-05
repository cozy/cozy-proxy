fs = require("fs")
should = require('chai').Should()
async = require('async')

Client = require("request-json").JsonClient
Adapter = require "../lib/adapter"

client = new Client "http://localhost:9101/"
adapter = new Adapter()


describe "Adapter", ->
	describe "Initialize keys", ->

		before (done) ->
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
       		adapter.initializeKeys "password", (err) =>
           		@err = err
           		done()

    	it "Then no error is returned", ->
       		should.not.exist @err

	describe "Update keys", ->

    	it "When I update keys", (done) ->
       		adapter.updateKeys "newPassword", (err) =>
           		@err = err
           		done()

    	it "Then no error is returned", ->
       		should.not.exist @err

	describe "Delete keys", ->

    	it "When I delete keys", (done) ->
       		adapter.deleteKeys (err) =>
           		@err = err
           		done()

    	it "Then no error is returned", ->
       		should.not.exist @err

	describe "Initialize keys in a second connexion", ->

    	it "When I initialize keys", (done) ->
       		adapter.initializeKeys "newPassword", (err) =>
           		@err = err
           		done()

    	it "Then no error is returned", ->
       		should.not.exist @err


