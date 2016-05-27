passport     = require 'passport'
randomstring = require 'randomstring'
request      = require 'request-json'
async        = require 'async'

User         = require '../models/user'
Instance     = require '../models/instance'
helpers      = require '../lib/helpers'
localization = require '../lib/localization_manager'
passwordKeys = require '../lib/password_keys'
otpManager   = require '../lib/2fa_manager'


getEnv = (callback) ->
    async.parallel(
        env: (done) ->
            User.getUsername (err, username) ->
                return done err if err

                done null,
                    username: username
                    apps:     Object.keys require('../lib/router').getRoutes()

        otp: (done) ->
            otpManager.getAuthType (err, otp) ->
                return done err if err

                done null, !!otp

        locale: (done) ->
            Instance.getLocale (err, locale) ->
                return done err if err

                localization.locale locale
                done null, locale

    , (err, res) ->
        env     = res.env
        env.otp = res.otp
        callback err, env
    )


module.exports.registerIndex = (req, res, next) ->
    getEnv (err, env) ->
        if err
            error          = new Error "[Error to access cozy user] #{err.code}"
            error.status   = 500
            error.template = name: 'error'
            next error

        else if env.username
            res.redirect '/login'

        else
            localization.locale req.headers['accept-language']
            res.render 'index', env: env


module.exports.register = (req, res, next) ->
    hash = helpers.cryptPassword req.body.password
    userData =
        email:       req.body.email
        owner:       true
        password:    hash.hash
        salt:        hash.salt
        public_name: req.body.public_name
        timezone:    req.body.timezone
        activated:   true
        allow_stats: req.body.allow_stats
        docType:     'User'

    instanceData = locale: req.body.locale

    passwdValidationError = User.validatePassword req.body.password
    validationErrors = User.validate userData, passwdValidationError

    unless Object.keys(validationErrors).length
        User.all (err, users) ->
            if err? then next new Error err
            else if users.length isnt 0
                error        = new Error 'User already registered.'
                error.status = 409
                next error
            else
                Instance.createOrUpdate instanceData, (err) ->
                    return next new Error err if err

                    User.createNew userData, (err) ->
                        return next new Error err if err

                        # at first load, 'en' is the default locale
                        # we must change it now if it has changed
                        localization.locale req.body.locale
                        next()
    else
        error        = new Error 'Errors in validation'
        error.errors = validationErrors
        error.status = 400
        next error


module.exports.loginIndex = (req, res, next) ->
    getEnv (err, env) ->
        if err
            next new Error err
        else
            return res.redirect '/register' unless env.username
            res.set 'X-Cozy-Login-Page', 'true'
            res.render 'index', env: env


module.exports.forgotPassword = (req, res, next) ->
    User.first (err, user) ->
        if err
            next new Error err

        else unless user
            err         = new Error 'No user registered.'
            err.status  = 400
            err.headers = 'Location': '/register/'
            next err

        else
            key = randomstring.generate()
            Instance.setResetKey key
            Instance.first (err, instance) ->
                return next err if err
                instance ?= domain: 'domain.not.set'
                helpers.sendResetEmail instance, user, key, (err, result) ->
                    return next new Error 'Email cannot be sent' if err
                    res.sendStatus 204


module.exports.resetPasswordIndex = (req, res, next) ->
    getEnv (err, env) ->
        if err
            next new Error err
        else
            if Instance.getResetKey() is req.params.key
                res.render 'index', env: env
            else
                res.redirect '/'


module.exports.resetPassword = (req, res, next) ->
    key = req.params.key
    newPassword = req.body.password

    User.first (err, user) ->

        if err? then next new Error err

        else if not user?
            err = new Error localization.t "reset error no user"
            err.status = 400
            err.headers = 'Location': '/register/'
            next err

        else

            if Instance.getResetKey() is req.params.key
                validationErrors = User.validatePassword newPassword

                unless Object.keys(validationErrors).length
                    data = password: helpers.cryptPassword(newPassword).hash
                    user.merge data, (err) ->
                        if err? then next new Error err
                        else
                            Instance.resetKey = null
                            passwordKeys.resetKeys newPassword, (err) ->

                                if err? then next new Error err
                                else
                                    passport.currentUser = null
                                    res.sendStatus 204

                else
                    error = new Error 'Errors in validation'
                    error.errors = validationErrors
                    error.status = 400
                    next error

            else
                error = new Error localization.t "reset error invalid key"
                error.status = 400
                next error


module.exports.logout = (req, res) ->
    req.logout()
    res.sendStatus 204


module.exports.authenticated = (req, res) ->
    res.status(200).send isAuthenticated: req.isAuthenticated()
