passport = require 'passport'
qs = require 'querystring'

localization = require '../lib/localization_manager'
passwordKeys = require '../lib/password_keys'
otpManager = require '../lib/2fa_manager'
url = require 'url'
User = require '../models/user'

# customize passport authenticate
module.exports.authenticate = (req, res, next) ->
    process = (err, user) ->
        if err
            next new Error localization.t 'error server'
        else if user is undefined or not user
            error = new Error localization.t 'error bad credentials'
            error.status = 401
            next error
        else
            passwordKeys.initializeKeys req.body.password, (err) ->
                if err
                    next new Error localization.t 'error keys not intialized'
                else
                    postLogin user

    # Dispatching the process to the right 2FA method (none, HOTP or TOTP)
    postLogin = (user) ->
        otpManager.getAuthType (err, otpAuth) ->
            if err
                msg = localization.t "error login failed"
                error = new Error msg
                error.status = 401
                next error
            else unless otpAuth
                req.logIn user, (err, info) ->
                    if err
                        msg = localization.t "error login failed"
                        error = new Error msg
                        error.status = 401
                        next error
                    else
                        res.status(200).send success: true
            else
                passport.authenticate(otpAuth, processOtp)(req, res, next)

    processOtp = (err, user) ->
        if err
            msg = localization.t err
            error = new Error msg
            next error
        else if not user and user isnt undefined
            msg = localization.t "error otp invalid code"
            error = new Error msg
            error.status = 401
            next error
        else
            User.first (err, user) ->
                req.logIn user, (err, info) ->
                    if err
                        msg = localization.t "error login failed"
                        error = new Error msg
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
