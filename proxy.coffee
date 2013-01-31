httpProxy = require 'http-proxy'
express = require 'express'
randomstring = require 'randomstring'
bcrypt = require 'bcrypt'
redis = require 'redis'

RedisStore = require('connect-redis')(express)
Client = require('request-json').JsonClient

passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
helpers = require './helpers'
middlewares = require './middlewares'

UserManager = require('./models').UserManager
InstanceManager = require('./models').InstanceManager

## Passport / Authentication
configurePassport = (userManager) ->
    passport.currentUser = null
    passport.serializeUser = (user, done) ->
        done null, user._id
     
    # This caching should be studied...
    passport.deserializeUser = (id, done) ->
        if passport.currentUser? and id is passport.currentUser._id
            done null, passport.currentUser
        else
            done null, null

    passport.use new LocalStrategy (email, password, done) ->
        userManager.all (err, users) ->
            checkResult = (err, res) ->
                if err
                    console.log "bcrypt checking failed"
                    done err, null
                else if res
                    passport.currentUser = users[0].value
                    passport.currentUser.id = users[0].value._id
                    done err, users[0].value
                else
                    done err, null

            if err
                console.log err
                done err, null
            else if users is undefined or not users
                done err, null
            else if users and users.length == 0
                done err, null
            else
                bcrypt.compare password, users[0].value.password, checkResult

# Proxy Class : handles redirection and authentication
class exports.CozyProxy

    # Port on which this server listens
    proxyPort: 9104

    # Default port for redirection
    defaultPort: 9103

    # Routes for app redirections
    routes: {}

    constructor: ->
        @app = express()
        @proxy = new httpProxy.RoutingProxy()
        @proxy.source.port = 9104
        @userManager = new UserManager()
        @instanceManager = new InstanceManager()
        configurePassport @userManager

        @app.enable 'trust proxy'
        @app.set 'view engine', 'jade'
        @app.use express.static(__dirname + '/public')
        @app.use middlewares.selectiveBodyParser
        secretKey = randomstring.generate()
        @app.use express.cookieParser secretKey
        @app.use express.session
            secret: secretKey
            store: new RedisStore(db:'cozy')
            cookie:
                maxAge: 30 * 86400 * 1000
        @app.use passport.initialize()
        @app.use passport.session()

        @app.use (err, req, res, next) ->
            console.error err.stack
            res.send 500, 'Something broke!'
            
        @setControllers()

    setControllers: ->
        @app.get "/routes", @showRoutesAction
        @app.get "/routes/reset", @resetRoutesAction

        @app.get '/register', @registerView
        @app.post '/register', @registerAction
        @app.get '/login', @loginView
        @app.post '/login', @loginAction
        @app.post "/login/forgot", @forgotPasswordAction
        @app.get '/password/reset/:key', @resetPasswordView
        @app.post '/password/reset/:key', @resetPasswordAction
        @app.get '/logout', @logoutAction
        @app.get '/authenticated', @authenticatedAction

        @app.all '/apps/:name/*', @redirectAppAction
        @app.all '/*', @defaultRedirectAction
        
    # Start proxy server listening.
    start: (port) ->
        @proxyPort = port if port
        @server = @app.listen(process.env.PORT || @proxyPort)
        
    # Stop proxy server listening.
    stop: ->
        @server.close()

    ### helpers ###
    
    sendSuccess: (res, msg, code=200) ->
        res.send success: true, msg: msg, code

    sendError: (res, msg, code=500) ->
        res.send error: true, msg: msg, code

    ### Routes ###

    # Default redirection send requests to home.
    defaultRedirectAction: (req, res) =>
        if req.isAuthenticated()
            buffer = httpProxy.buffer(req)
            @proxy.proxyRequest req, res,
                host: 'localhost'
                port: @defaultPort
                buffer: buffer
        else
            res.redirect '/login'

    # Redirect application, redirect request depening on app name.
    redirectAppAction: (req, res) =>
        if req.isAuthenticated()
            buffer = httpProxy.buffer(req)
            appName = req.params.name
            req.url = req.url.substring "/apps/#{appName}".length
            port = @routes[appName]

            if port?
                @proxy.proxyRequest req, res,
                    host: 'localhost'
                    port: @routes[req.params.name]
                    buffer: buffer
            else
                res.send 404
        else
            res.redirect '/login'

    # Return success: true if user is authenticated, false either.
    authenticatedAction: (req, res) =>
        res.send success: req.isAuthenticated()

    # Reset routes with routes coming from application app.
    resetRoutesAction: (req, res) =>
        console.log "GET reset/routes start route reseting"
        @resetRoutes (error) ->
            if error
                res.send error
            else
                console.log "Reset routes succeeded"
                send 200

    # Return currently set routes.
    showRoutesAction: (req, res) =>
        res.send @routes

    # Clear routes then build them from Cozy Home data.
    resetRoutes: (callback) ->
        @routes = {}
        client = new Client "http://localhost:#{@defaultPort}/"
        client.get "api/applications/", (error, response, apps) =>
            return callback(error) if error
            return callback new Error(apps.msg) if apps.error?
            try
                for app in apps.rows
                    @routes[app.slug] = app.port if app.port?
                callback()
            catch err
                return callback err

    ### Authentication ###

    loginView: (req, res) =>
        @userManager.all (err, users) ->
            if users.length > 0
                res.render 'login'
            else
                res.redirect 'register'

    registerView: (req, res) =>
        @userManager.all (err, users) ->
            if users.length is 0
                res.render 'register'
            else
                res.redirect 'login'
    
    authenticatedAction: (req, res) =>
        res.send success: req.isAuthenticated()

    authenticate: (req, res) =>
        # Check user credentials and keep user authentication through session.
        answer = (err) =>
            if err
                @sendError res, "Login failed"
            else
                @sendSuccess res, "Login succeeded"

        authenticator = passport.authenticate 'local', (err, user) =>
            if err
                console.log err
                @sendError res, "Server error occured.", 500
            else if user is undefined or not user
                console.log err if err
                @sendError res, "Wrong password", 400
            else
                req.logIn user, {}, answer

        authenticator(req, res)


    loginAction: (req, res) =>
        req.body.username = "owner"
        @authenticate(req, res)

    # Clear authentication credentials from session for current user.
    logoutAction: (req, res) =>
        req.logOut()
        passport.currentUser = null
        
        res.send
            success: true
            msg: "Log out succeeded."

    # Create user with given credentials
    registerAction: (req, res) =>
        email = req.body.email
        password = req.body.password

        createUser = (url) =>
            hash = helpers.cryptPassword password

            user =
                email: email
                owner: true
                password: hash.hash
                salt: hash.salt
                activated: true
                docType: "User"

            @userManager.create user, (err, code, user) =>
                if err
                    console.log err
                    @sendError res, "Server error occured.", 500
                else
                    req.body.username = "owner"
                    @authenticate req, res

        user =
            email: email
            password: password
            
        if @userManager.isValid user
            @userManager.all (err, users) =>
                if err
                    console.log err
                    @sendError res, "Server error occured.", 500
                else if users.length
                    @sendError res, "User already registered.", 400
                else
                    createUser()
        else
            @sendError res, @userManager.error, 400

    # Send an email with a temporary key that allows acceess to
    # a change password page.
    forgotPasswordAction: (req, res) =>

        sendEmail = (instances, user, key) =>
            if instances.length > 0
                instance = instances[0].value
            else
                instance = domain: "domain.not.set"

            helpers.sendResetEmail instance, user, key, (err, result) =>
                if err
                    console.log err
                    @sendErrorr res, "Email cannot be sent"
                else
                    @sendSuccess res, "Reset email sent."


        @userManager.all (err, users) =>
            if err
                console.log err
                @sendError res, "Server error occured.", 500
            else if users.length == 0
                res.send
                    error: true
                    msg: "No user set, register first error occured.", 500
            else
                user = users[0].value
                key = helpers.genResetKey()
                @instanceManager.all (err, instances) =>
                    if err
                        console.log err
                        @sendError res, "Server error occured.", 500
                    else
                        sendEmail instances, user, key

    # Display reset password view, only if given key is valid.
    resetPasswordView: (req, res) =>
        helpers.checkKey req.params.key, (err, isKeyOk) =>
            if err
                console.log err
                @sendError res, "Server error occured.", 500
            else if isKeyOk
                res.render 'reset', resetKey: req.params.key
            else
                res.redirect '/'

    # Check password validity, then change password, then clear reset key
    # from redis cache.
    resetPasswordAction: (req, res) =>
        key = req.params.key
        newPassword = req.body.password

        checkKey = (user) ->
            helpers.checkKey key, (err, isKeyOk) =>
                if err
                    @sendError res, "Server error occured.", 500
                else if not isKeyOk
                    @sendError res, "Key is not valid.", 400
                else
                    changeUserData user

        changeUserData = (user) =>
            if newPassword? and newPassword.length > 5
                data = password: helpers.cryptPassword(newPassword).hash
            
                @userManager.merge user, data, (err) =>
                    if err
                        @sendError res, 'User cannot be updated'
                    else
                        client = redis.createClient()
                        client.set "resetKey", "", =>
                            @sendSuccess res, 'Password updated successfully'
            else
                @sendError res, 'Password is too short', 400

        @userManager.all (err, users) =>
            if err
                console.log err
                @sendError res, "Server error occured.", 500
            else if users.length == 0
                @sendError res, "No user registered.", 400
            else
                checkKey users[0].value
