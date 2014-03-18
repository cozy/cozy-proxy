passport = require 'passport'
randomstring = require 'randomstring'
locale = require 'locale'

User = require '../models/user'
Instance = require '../models/instance'
helpers = require '../lib/helpers'
localization = require '../lib/localization_manager'
passwordKeys = require '../lib/password_keys'

timezones = require '../lib/timezones'
supportedLocales = require('../config').supportedLanguages

module.exports.registerIndex = (req, res) ->
    User.first (err, user) ->
        unless user?
            supported = new locale.Locales supportedLocales
            locales = new locale.Locales req.headers['accept-language']
            bestMatch = locales.best(supported).language
            polyglot = localization.getPolyglotByLocale bestMatch
            res.render 'register.jade', polyglot: polyglot, timezones: timezones
        else
            res.redirect 'login'

module.exports.register = (req, res, next) ->

    hash = helpers.cryptPassword req.body.password
    userData =
        email: req.body.email
        owner: true
        password: hash.hash
        salt: hash.salt
        public_name: req.body.public_name
        timezone: req.body.timezone
        activated: true
        docType: "User"

    instanceData = locale: req.body.locale

    validationErrors = User.validate userData
    if validationErrors.length is 0
        User.all (err, users) ->
            if err? then next new Error err
            else if users.length isnt 0
                error = new Error "User already registered."
                error.status = 409
                next error
            else
                Instance.createOrUpdate instanceData, (err) ->
                    if err then next new Error err
                    else
                        User.create userData, (err, user) ->
                            if err then next new Error err
                            else next()
    else
        error = new Error validationErrors
        error.status = 400
        next error

module.exports.loginIndex = (req, res) ->
    User.first (err, user) ->
        if user?
            # display name management
            if user.public_name?.length > 0 and false then name = user.public_name
            else
                name = helpers.hideEmail user.email
                words = name.split ' '
                name = words.map((word) ->
                    return word.charAt(0).toUpperCase() + word.slice 1
                ).join ' '

            polyglot = localization.getPolyglot()
            res.render 'login.jade', polyglot: polyglot, name: name
        else
            res.redirect 'register'

module.exports.forgotPassword = (req, res, next) ->

    User.first (err, user) ->
        if err?
            next new Error err
        else if not user?
            err = new Error "No user registered."
            err.status = 400
            err.headers = 'Location': '/register/'
            next err
        else
            key = randomstring.generate()
            Instance.setResetKey key
            Instance.first (err, instance) ->
                if err? then next new Error err
                else if not instance?
                    instance = domain: "domain.not.set"

                helpers.sendResetEmail instance, user, key, (err, result) ->
                    if err?
                        next new Error "Email cannot be sent"
                    else
                        res.send 204

module.exports.resetPasswordIndex = (req, res) ->
    if Instance.getResetKey() is req.params.key
        polyglot = localization.getPolyglot()
        res.render 'reset.jade', polyglot: polyglot, resetKey: req.params.key
    else
        res.redirect '/'

module.exports.resetPassword = (req, res) ->
    key = req.params.key
    newPassword = req.body.password

    User.first (err, user) ->
        if err? then next new Error err
        else if not user?
            err = new Error "No user registered."
            err.status = 400
            err.headers = 'Location': '/register/'
            next err
        else
            if Instance.getResetKey() is req.params.key

                validationErrors = User.validatePassword newPassword
                if validationErrors.length is 0
                    data = password: helpers.cryptPassword(newPassword).hash
                    user.updateAttributes data, (err) ->
                        if err? then next new Error err
                        else
                            Instance.resetKey = null
                            passwordKeys.resetKeys (err) ->
                                if err? then next new Error err
                                else
                                    res.send 204
                else
                    error = new Error validationErrors
                    error.status = 400
                    next error
            else
                error = new Error "Key is invalid"
                error.status = 400
                next error

module.exports.logout = (req, res) ->
    req.logout()
    # clear in-memory cache
    passport.currentUser = null
    res.send 204

module.exports.authenticated = (req, res) ->
    res.send 200, isAuthenticated: req.isAuthenticated()

