passport = require 'passport'
qs = require 'querystring'
bcrypt = require 'bcrypt'

localization = require '../lib/localization_manager'
passwordKeys = require '../lib/password_keys'

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
                    req.logIn user, (err, info) ->
                        if err
                            error = new Error localization.t "error login failed"
                            error.status = 401
                            next error
                        else
                            res.send 200, success: true
    passport.authenticate('local', process)(req, res, next)

module.exports.isAuthenticated = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        url = "/login#{req.url}"
        url += "?#{qs.stringify req.query}" if req.query.length
        res.redirect url


# Authenticate all the connections to the Git repository via Basic HTTP
# authentication, so that the Git client prompt for username and password.
#
# We do not use passport in that case because we want the user to input the
# email as its username (along with its Cozy password). Besides, the server
# needs to send a response with a "WWW-Authenticate" header.
module.exports.authenticateWithEmail = (req, res, next) ->

    # We want to pause the request during the authentication and resume it
    # later, otherwise the Git push request is not handled properly
    req.pause()

    unauthorized = ->
        res.statusCode = 401
        res.setHeader 'WWW-Authenticate', 'Basic realm="Secure Area"'
        return res.end 'Unauthorized'

    header = req.headers['authorization']
    return unauthorized() if not header?

    credentials = new Buffer(header.split(' ')[1], 'base64').toString 'ascii'
    [email, password] = credentials.split ':'

    User.first (err, user) ->
        if err? or not user?
            return unauthorized()
        else
            bcrypt.compare password, user.password, (err, result) ->
                if err? or not result or user.email isnt email
                    return unauthorized()
                else
                    next()
                    req.resume()
