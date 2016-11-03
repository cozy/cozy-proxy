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
Authentication = require '../middlewares/authentication'

getEnv = (callback) ->
    User.getUsername (err, username) ->
        return callback err if err

        otpManager.getAuthType (err, otp) ->
            return callback err if err

            env =
                username: username
                otp:      !!otp
                apps:     Object.keys require('../lib/router').getRoutes()

            callback null, env

module.exports.onboarding = (req, res, next) ->
    getEnv (err, env) ->
        if err
            error          = new Error "[Error to access cozy user] #{err.code}"
            error.status   = 500
            error.template = name: 'error'
            next error
        else
            # get user data
            User.first (err, userData) ->
                if err
                    error = new Error "[Error to access cozy user] #{err.code}"
                    error.status   = 500
                    error.template = name: 'error'
                    next error

                # According to steps changes
                # If authenticatable but not registered yet
                # -> need authentication to continue next registration steps
                if not req.isAuthenticated() and \
                    User.isAuthenticatable(userData) and \
                    not User.isRegistered(userData)
                        res.redirect '/login?next=/register'
                # if already registered -> login to cozy home
                else if User.isRegistered userData
                    res.redirect '/login'
                # access onboarding, here the user is not register and:
                # - either he is authenticatable and will be authenticated
                # - either he is not authenticatable (first three steps)
                else
                    if userData
                        hasValidInfos = User.checkInfos userData
                        env.hasValidInfos = hasValidInfos
                    localization.setLocale req.headers['accept-language']
                    # We need to pass a flag to signal the view is in
                    # registration mode
                    # TODO: this one is temporary, and need to be removed
                    # when we merge CSS again.
                    env.currentStep = User.getCurrentOnboardingStep userData
                    res.render 'index', {env: env, onboarding: true}


# Save unauthenticated user document (only if password doesn't exist)
# Expected request body format (? means optionnal)
# ?password
# ?allowStats
# ?CGUaccepted
# onboardedSteps
module.exports.saveUnauthenticatedUser = (req, res, next) ->
    requestData = req.body

    userToSave = {}
    dataErrors = {}
    # grab data from the request body
    if requestData.password
        hash = helpers.cryptPassword requestData.password
        userToSave.password = hash.hash
        userToSave.salt = hash.salt
        passwordValidationError =
            User.validatePassword requestData.password
        if Object.keys(passwordValidationError).length
            dataErrors.password = passwordValidationError.password
    [
        'allow_stats',
        'isCGUaccepted',
        'onboardedSteps'
    ].forEach (property) =>
        if requestData[property]
            userToSave[property] = requestData[property]

    # other data
    userToSave.owner = true
    instanceData = locale: requestData.locale

    unless Object.keys(dataErrors).length
        User.all (err, users) ->
            return next new Error err if err
            # if existing user document with password -> request rejected
            if users[0]?.password
                error        = new Error 'Not authorized'
                error.status = 401
                return next error
            else if users.length
                users[0].merge userToSave, (err) ->
                    return next new Error err if err
                    if requestData.password?
                        return Authentication.authenticate(req, res, next)
                    else
                        res
                            .status(200)
                            .send(result: 'User data correctly updated')
            else
                Instance.createOrUpdate instanceData, (err) ->
                    return next new Error err if err
                    User.createNew userToSave, (err) ->
                        return next new Error err if err

                        # at first load, 'en' is the default locale
                        # we must change it now if it has changed
                        localization.setLocale requestData.locale
                        res.status(201).send(
                            result: 'User data correctly created'
                        )
    else
        error        = new Error 'Errors with data'
        error.errors = dataErrors
        error.status = 400
        next error


# Save user document if authenticated
# Expected request body format (? means optionnal)
# ?public_name
# ?timezone
# ?email
# onboardedSteps
module.exports.saveAuthenticatedUser = (req, res, next) ->
    requestData = req.body

    userToSave = {}
    errors = {}
    # grab data from the request body
    [
        'public_name',
        'email',
        'timezone',
        'onboardedSteps'
    ].forEach (property) =>
        if requestData[property]
            userToSave[property] = requestData[property]

    # if final step done, user is registred
    if User.isRegistered userToSave
        userToSave.activated = true

    validationErrors = User.validate userToSave

    unless Object.keys(validationErrors).length
        User.all (err, users) ->
            return next new Error err if err
            if users.length
                users[0].merge userToSave, (err) ->
                    return next new Error err if err
                    res.status(200).send(result: 'User data correctly updated')
            else
                error        = new Error 'User document not found'
                error.status = 404
                return next error

    else
        error        = new Error 'Errors with validation'
        error.errors = validationErrors
        error.status = 400
        next error


module.exports.loginIndex = (req, res, next) ->
    getEnv (err, env) ->
        if err
            next new Error err
        else
            # get user data
            User.first (err, userData) ->
                if err
                    error = new Error "[Error to access cozy user] #{err.code}"
                    error.status   = 500
                    error.template = name: 'error'
                    next error

                if not User.isRegistered userData
                    if not User.isAuthenticatable userData
                        return res.redirect '/register'
                    # avoid looping between register and login redirection
                    else if req.url isnt '/login?next=/register'
                        return res.redirect '/login?next=/register'

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
            err = new Error 'reset error no user'
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
                error = new Error 'reset error invalid key'
                error.status = 400
                next error


module.exports.logout = (req, res) ->
    req.logout()
    res.sendStatus 204


module.exports.authenticated = (req, res) ->
    res.status(200).send isAuthenticated: req.isAuthenticated()
