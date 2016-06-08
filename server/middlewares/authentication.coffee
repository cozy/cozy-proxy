passport = require 'passport'
qs = require 'querystring'

passwordKeys = require '../lib/password_keys'
otpManager = require '../lib/2fa_manager'
url = require 'url'
User = require '../models/user'

# customize passport authenticate
module.exports.authenticate = (req, res, next) ->
    process = (err, user) ->
        if err
            error = new Error 'error server'
            next error
        else if user is undefined or not user
            error = new Error 'error bad credentials'
            error.status = 401
            next error
        else
            passwordKeys.initializeKeys req.body.password, (err) ->
                if err
                    error = new Error 'error keys not intialized'
                    next error
                else
                    postLogin user

    # Dispatching the process to the right 2FA method (none, HOTP or TOTP)
    postLogin = (user) ->
        otpManager.getAuthType (err, otpAuth) ->
            if err
                error = new Error 'error login failed'
                error.status = 401
                next error
            else unless otpAuth
                req.logIn user, (err, info) ->
                    if err
                        error = new Error 'error login failed'
                        error.status = 401
                        next error
                    else
                        res.status(200).send success: true
            else
                passport.authenticate(otpAuth, processOtp)(req, res, next)

    processOtp = (err, user) ->
        if err
            error = new Error err
            next error
        else if not user and user isnt undefined
            error = new Error 'error otp invalid code'
            error.status = 401
            next error
        else
            User.first (err, user) ->
                req.logIn user, (err, info) ->
                    if err
                        error = new Error 'error login failed'
                        error.status = 401
                        next error
                    else
                        res.status(200).send success: true

    passport.authenticate('local', process)(req, res, next)

module.exports.isAuthenticated = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        url = "/login"
        url += "?next=#{encodeURIComponent req.url}" unless req.url is '/'
        url += "&#{qs.stringify req.query}" if req.query.length
        res.redirect url

module.exports.isNotAuthenticated = (req, res, next) ->
    if req.isAuthenticated()
        res.redirect '/'
    else
        next()
