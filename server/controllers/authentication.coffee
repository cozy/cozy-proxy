passport     = require 'passport'
randomstring = require 'randomstring'
request      = require 'request-json'

User         = require '../models/user'
Instance     = require '../models/instance'
helpers      = require '../lib/helpers'
localization = require '../lib/localization_manager'
passwordKeys = require '../lib/password_keys'


module.exports.registerIndex = (req, res) ->
    User.first (err, user) ->
        if user?
            res.redirect '/login'
        else
            localization.setLocale req.headers['accept-language']
            res.render "index"


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
                    return next new Error err if err

                    User.createNew userData, (err) ->
                        return next new Error err if err

                        # at first load, 'en' is the default locale
                        # we must change it now if it has changed
                        localization.setLocale req.body.locale
                        next()
    else
        error = new Error validationErrors
        error.status = 400
        next error


module.exports.registerEmail = (req, res, next) ->
    accountData =
        id:                null
        label:             req.body.email
        name:              req.body.email.split('@')[0]
        login:             req.body.username or req.body.email
        password:          req.body.password
        accountType:       "IMAP"
        draftMailbox:      ""
        favoriteMailboxes: null
        imapPort:          req.body.port
        imapSSL:           req.body.ssl
        imapServer:        req.body.server
        imapTLS:           false
        smtpLogin:         req.body.username or req.body.email
        smtpMethod:        "PLAIN"
        smtpPassword:      req.body.password
        smtpPort:          "465"
        smtpSSL:           req.body.ssl
        smtpServer:        req.body.server
        smtpTLS:           false
        mailboxes:         ""
        sentMailbox:       ""
        trashMailbox:      ""

    console.log accountData

    emailsClient = request.newClient 'http://localhost:9125/'
    globalRes = res

    console.log "Creating email account..."
    emailsClient.post 'account', accountData, (err, res, body) ->
        if err?
            console.log "Error at email account creation", err
            error = new Error "User already registered."
            error.status = 409
            next error
        else if res?.statusCode isnt 200
            console.log "Error at email account creation response", body
            error = new Error body
            error.status = 409
            next error
        else
            globalRes.send 204


module.exports.loginIndex = (req, res) ->
    User.first (err, user) ->
        return res.redirect '/register' unless user?

        # display name management
        if user.public_name?.length > 0 then name = user.public_name
        else
            name = helpers.hideEmail user.email
            words = name.split ' '
            name = words.map((word) ->
                return word.charAt(0).toUpperCase() + word.slice 1
            ).join ' '

        res.render "index", name: name


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
        res.render "index", resetKey: req.params.key
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

                if validationErrors.length is 0
                    data = password: helpers.cryptPassword(newPassword).hash
                    user.merge data, (err) ->
                        if err? then next new Error err
                        else
                            Instance.resetKey = null
                            passwordKeys.resetKeys (err) ->

                                if err? then next new Error err
                                else
                                    passport.currentUser = null
                                    res.send 204

                else
                    error = new Error validationErrors
                    error.status = 400
                    next error

            else
                error = new Error localization.t "reset error invalid key"
                error.status = 400
                next error


module.exports.logout = (req, res) ->
    req.logout()
    res.send 204


module.exports.authenticated = (req, res) ->
    res.send 200, isAuthenticated: req.isAuthenticated()
