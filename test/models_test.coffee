should = require('chai').Should()
UserManager = require('../models').UserManager

describe "Models", ->

    before (done) ->
        @userManager = new UserManager()
        @userManager.dbClient.put 'request/user/all/destroy/', {}, (err) ->
            done()

    after (done) ->
        @userManager.dbClient.put 'request/user/all/destroy/', {}, (err) ->
            done()

    describe "creation", ->
        it "When I create an user", (done) ->
             
            user =
                email: "test@cozycloud.cc"
                owner: true
                password: "password"
                activated: true

            @userManager.create user, (err, code, user) =>
                @err = err
                @code = code
                @user = user
                done()

        it "Then I got no error", ->
            should.not.exist @err
            @code.should.equal 201

        it "When I request for users", (done) ->
            @userManager.all (err, users) =>
                @users = users
                done()

        it "Then I find my new user", ->
            @users.length.should.equal 1
            @user._id.should.equal @users[0].value._id

    describe "update", ->
        it "When I modify this user", (done) ->
            @user.email = "new@cozycloud.cc"
            @userManager.merge @user, email: @user.email, (err, code, body) =>
                @err = err
                done()
            
        it "Then I got no error", ->
            should.not.exist @err

        it "When I request for users", (done) ->
            @userManager.all (err, users) =>
                @users = users
                done()

        it "Then I find my user modified", ->
            @users.length.should.equal 1
            @user.email.should.equal @users[0].value.email

describe "User", ->
    describe "isValidUser", ->
        before ->
            @userManager = new UserManager()

        it "wrong email", ->
            user =
                email: "test"
                password: "password"
            @userManager.isValid(user).should.equal false
            should.exist @userManager.error
        it "wrong password", ->
            user =
                email: "test"
                password: "pas"
            @userManager.isValid(user).should.equal false
            should.exist @userManager.error
        it "right email and right password", ->
            user =
                email: "test@cozycloud.cc"
                password: "password"
            @userManager.isValid(user).should.equal true
            should.not.exist @userManager.error
