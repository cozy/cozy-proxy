should = require('chai').Should()
helpers = require './helpers'
User = require "#{helpers.prefix}server/models/user"

describe "Models", ->

    before helpers.createAllRequests
    before helpers.deleteAllUsers
    after  helpers.deleteAllUsers

    describe "creation", ->
        it "When I create an user", (done) ->

            user =
                email: "test@cozycloud.cc"
                owner: true
                password: "password"
                activated: true

            User.create user, (err, user) =>
                @err = err
                @user = user
                done()

        it "Then I got no error", ->
            should.not.exist @err
            should.exist @user

        it "When I request for users", (done) ->
            User.request 'all', (err, users) =>
                @users = users
                done()

        it "Then I find my new user", ->
            should.exist @users
            @users.length.should.equal 1
            @user.id.should.equal @users[0].id

    describe "update", ->
        it "When I modify this user", (done) ->
            email = "new@cozycloud.cc"
            @user.updateAttributes email: email, (err) =>
                @err = err
                done()

        it "Then I got no error", ->
            should.not.exist @err

        it "When I request for users", (done) ->
            User.request 'all', (err, users) =>
                @users = users
                done()

        it "Then I find my user modified", ->
            should.exist @users
            @users.length.should.equal 1
            @user.email.should.equal @users[0].email

describe "User", ->
    describe "isValidUser", ->

        it "wrong email", ->
            user =
                email: "test"
                password: "password"
                timezone: "Europe/Paris"
            User.validate(user).length.should.equal 1

        it "wrong password", ->
            user =
                email: "test@cozycloud.cc"
                password: "pas"
                timezone: "Europe/Paris"
            User.validate(user).length.should.equal 1

        it "wrong timezone", ->
            user =
                email: "test@cozycloud.cc"
                password: "password"
                timezone: "blabla"
            User.validate(user).length.should.equal 1

        it "right email, right password and right timezone", ->
            user =
                email: "test@cozycloud.cc"
                password: "password"
                timezone: "Europe/Paris"
            User.validate(user).length.should.equal 0
