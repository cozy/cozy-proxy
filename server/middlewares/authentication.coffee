passport = require 'passport'
qs = require 'querystring'

NotificationHelper = require 'cozy-notifications-helper'
notificationHelper = new NotificationHelper

localization = require '../lib/localization_manager'
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
<<<<<<< HEAD
            msg = localization.t "error otp invalid code"
            User.first (err, user) ->
                recoveryCodes = user.encryptedRecoveryCodes[0]
                if parseInt(req.body.authcode) in recoveryCodes
                    # Disabling recovery code
                    index = recoveryCodes.indexOf(parseInt req.body.authcode)
                    recoveryCodes.splice index, 1
                    user.updateAttributes
                        encryptedRecoveryCodes: recoveryCodes
                    , ->
                        # Allowing the authentication
                        str = localization.t "authenticated with recovery code"
                        str += recoveryCodes.length + " "
                        str += localization.t "recovery codes left"
                        notificationHelper.createTemporary
                            text: str
                        , ->
                            if recoveryCodes.length is 0
                                str = localization.t "recovery codes warning"
                                notificationHelper.createTemporary
                                    text: str
                            authSuccess()
                else
                    error = new Error msg
                    error.status = 401
                    next error
        else
            authSuccess()

    authSuccess = () ->
        User.first (err, user) ->
            req.logIn user, (err, info) ->
                if err
                    msg = localization.t "error login failed"
                    error = new Error msg
                    error.status = 401
                    next error
                else
                    res.status(200).send success: true
=======
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
>>>>>>> 1cddd2558e75ceafcbba6f238db8b9aa7879865d

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
