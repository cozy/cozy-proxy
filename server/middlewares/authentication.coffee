passport = require 'passport'
qs = require 'querystring'

NotificationHelper = require 'cozy-notifications-helper'
notificationHelper = new NotificationHelper

localization = require '../lib/localization_manager'
passwordKeys = require '../lib/password_keys'
otpManager = require '../lib/2fa_manager'
url = require 'url'
User = require '../models/user'
logger = require('printit')
    date: true
    prefix: 'mid:auth'



makeError = (code, msg, original) ->
    err = new Error msg
    err.stack += "\n\nCaused by #{original}" if original
    err.status = code
    return err

loginFirstUser = (req, res, next) ->
    User.first (err, user) ->
        return next err if err
        req.logIn user, (err) ->
            if err then next makeError 401, 'error login failed', err
            else res.status(200).send success: true

createNotificationRecovery = (length, callback)->
    # Allowing the authentication
    # @TODO use polyglot interpolation
    text = localization.t "authenticated with recovery code"
    text += length + " "
    text += localization.t "recovery codes left"
    notificationHelper.createTemporary {text} , callback

disableRecoveryCode = (user, codes, index, callback) ->
    codes.splice index, 1
    changes = encryptedRecoveryCodes: JSON.stringify(codes)
    user.updateAttributes changes, callback

attemptRecoveryCodes = (user, req, res, next) ->
    User.first (err, user) ->
        if err
            next makeError 401, 'no user found', err
        else if not user.encryptedRecoveryCodes?
            next makeError 401, 'error otp invalid code'
        else
            codes = JSON.parse(user.encryptedRecoveryCodes)
            index = codes.indexOf(parseInt req.body.authcode)
            if index is -1 # invalid code
                next makeError 401, 'error otp invalid code'
            else
                disableRecoveryCode user, codes, index, (err) ->
                    if err
                        next makeError 401, 'error otp invalid code', err
                    else
                        createNotificationRecovery codes.length, (err) ->
                            # ignore err
                            logger.error(err) if err
                            loginFirstUser req, res, next

# passport API is not very convenient
simplepass = (strategy, req, res, next, handler) ->
    passport.authenticate(strategy, handler)(req, res, next)

# customize passport authenticate
module.exports.authenticate = (req, res, next) ->

    otpManager.getAuthType (err, otpAuth) ->
        return next makeError 401, 'error login failed', err if err

        simplepass 'local', req, res, next, (err, user) ->
            if err
                next makeError 401, 'error server', err
            else if not user
                next makeError 401, 'error bad credentials'
            else
                # initializeKeys now as we need them for OTP auth.
                passwordKeys.initializeKeys req.body.password, (err) ->
                    if err
                        next makeError 500, 'error keys not intialized', err
                    else if not otpAuth
                        req.logIn user, (err) ->
                            if err
                                next makeError 401, 'error login failed', err
                            else
                                res.status(200).send success: true
                    else # oauthStrategy
                        req.user = user
                        simplepass otpAuth, req, res, next, (err, user) ->
                            if err
                                next makeError(500, 'server error', err)
                            else if user
                                loginFirstUser req, res, next
                            else
                                attemptRecoveryCodes user, req, res, next

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
