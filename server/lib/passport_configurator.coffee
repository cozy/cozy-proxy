bcrypt = require 'bcrypt'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy

User = require '../models/user'

module.exports = ->

    # session variable
    passport.currentUser = null

    # serialize the user to cookie
    passport.serializeUser = (user, req, done) ->
        done null, user._id

    # deserialize the user from cookie
    passport.deserializeUser = (id, req, done) ->
        if passport.currentUser? and id is passport.currentUser._id
            done null, passport.currentUser
        else
            done null, false

    # strategy to use to identify the user
    # we currently only have the password field
    options = usernameField: 'password'
    passport.use new LocalStrategy options, (email, password, done) ->
        User.first (err, user) ->
            if err? or not user?
                done err, false
            else
                bcrypt.compare password, user.password, (err, result) ->
                    if err?
                        done err, false
                    else if result
                        passport.currentUser = user
                        passport.currentUser.id = user._id
                        done err, user
                    else
                        done err, false