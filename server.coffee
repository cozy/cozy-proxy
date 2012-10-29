httpProxy = require 'http-proxy'
express = require 'express'
passport = require 'passport'
bcrypt = require 'bcrypt'
redis = require 'redis'
LocalStrategy = require('passport-local').Strategy
RedisStore = require('connect-redis')(express)

Client = require('request-json').JsonClient
dbClient = new Client "http://localhost:7000/"

passport_utils = require './passport_utils'

process.on 'uncaughtException', (err) ->
    console.error err.message
    console.error err.stack

### Middlewares ###

#
mime = (req) ->
  str = req.headers['content-type'] || ''
  return str.split(';')[0]

selectiveBodyParser = (req, res, next) ->
    if req.url.indexOf("/routes") != 0 and req.url.indexOf("/login") != 0 and req.url.indexOf("/password") != 0 and req.url.indexOf("/register") != 0
        next()
    else
        # check Content-Type
        #return next() unless "application/json" is mime(req)

        # flag as parsed
        req._body = true

        # parse
        buf = ""
        req.setEncoding "utf8"
        req.on "data", (chunk) ->
            buf += chunk
        req.on "end", ->
            if buf.length > 0 and "{" isnt buf[0] and "[" isnt buf[0]
                return next(new Error("invalid json"))
            try
                if buf.length > 0
                    req.body = JSON.parse(buf)
                else
                    req.body = ""
                next()
            catch err
                #err.body = buf
                #err.status = 400
                #next err
                console.log err
                next()

## Passport / Authentication
passport.currentUser = null
passport.serializeUser = (user, done) ->
    done null, user._id
 
# This caching should be studied...
passport.deserializeUser = (id, done) ->
    if passport.currentUser? and id == passport.currentUser._id
        done null, passport.currentUser
    else
        done null, null
    #dbClient.get "data/#{id}/", (err, response, user) ->
        #if err
            #console.log "error"
            #done err, user
        #else if user?
            #done err, user
        #else
            #done err, null

passport.use new LocalStrategy (email, password, done) ->
    dbClient.post "request/user/all/", {}, (err, res, users) ->
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


# Proxy 
class exports.CozyProxy

    # Port on which this server listens
    proxyPort: 4000

    # Default port for redirection
    defaultPort: 3000

    # Routes for app redirections
    routes: {}

    constructor: ->
        @app = express()
        @proxy = new httpProxy.RoutingProxy()
        @proxy.source.port = 4000
        @dbClient = new Client "http://localhost:7000/"

        @app.enable 'trust proxy'
        @app.set 'view engine', 'jade'
        @app.use express.static(__dirname + '/public')
        @app.use selectiveBodyParser
        @app.use express.cookieParser 'secret'
        @app.use express.session
            secret: 'secret'
            store: new RedisStore(db:'cozy')
        @app.use passport.initialize()
        @app.use passport.session()

        @app.use (err, req, res, next) ->
            console.error err.stack
            res.send 500, 'Something broke!'
            
        @setControllers()

    setControllers: ->

        @app.post "/routes", @addRouteAction
        @app.delete "/routes/:name", @delRouteAction
        @app.get "/routes", @showRoutesAction
        @app.get "/routes/reset", @resetRouteAction

        @app.get '/register', @registerView
        @app.post '/register', @registerAction
        @app.get '/login', @loginView
        @app.post '/login', @loginAction
        @app.post "/login/forgot", @forgotPasswordAction
        @app.get '/password/reset/:key', @resetPasswordView
        @app.post '/password/reset/:key', @resetPasswordAction
        @app.get '/logout', @logoutAction

        @app.all '/apps/:name/*', @redirectAppAction
        @app.all '/*', @defaultRedirectAction
        
    # Start proxy server listening.
    start: (port) ->
        @proxyPort = port if port
        @server = @app.listen(process.env.PORT || @proxyPort)
        
    # Stop proxy server listening.
    stop: ->
        @server.close()

    # Clear routes then build them from Cozy Home data.
    resetRoutes: (callback) ->
        @routes = {}
        client = new Client("http://localhost:#{@defaultPort}/")
        client.get "api/applications/", (error, response, apps) =>
            return callback(error) if error
            return callback new Error(apps.msg) if apps.error?
            try
                for app in apps.rows
                    @routes[app.slug] = app.port if app.port?
                callback()
            catch err
                return callback err

    ### Controllers ###

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
            
    # Add a route to proxy routes if given request is correct. 
    addRouteAction: (req, res) =>
        routeInfos = req.body
        
        if not routeInfos.route? or not routeInfos.port?
            if process.env.NODE_ENV != "test"
                console.error "Wrong data were sent, route cannot be added"
            res.send 400
        else
            @routes[routeInfos.route] = routeInfos.port
            if process.env.NODE_ENV != "test"
                console.log "New route added #{routeInfos.route} redirect " + \
                            "to port #{routeInfos.port}"
            res.send 201

    # Remove a route that is given in parameter.
    delRouteAction: (req, res) =>
        route = "#{req.params.name}"

        delete @routes[route]
        if process.env.NODE_ENV != "test"
            console.log "Route removed : #{route}"
        res.send 204

    # Reset routes with routes coming from application app.
    resetRoutesAction: (req, res) =>
        @resetRoutes (error) ->
            if error then res.send error else send 200

    # Return currently set routes.
    showRoutesAction: (req, res) =>
        res.send @routes


    ### Authentication ###

    loginView: (req, res) =>
        @dbClient.post "request/user/all/", {}, (err, response, users) ->
            if users.length > 0
                res.render 'login'
            else
                res.redirect 'register'

    registerView: (req, res) =>
        @dbClient.post "request/user/all/", {}, (err, response, users) ->
            if users.length is 0
                res.render 'register'
            else
                res.redirect 'login'
    
    # Check user credentials and keep user authentication through session.
    loginAction: (req, res) =>
        answer = (err) ->
            if err
                res.send error: true, msg: "Login failed"
            else
                res.send success: true, msg: "Login succeeds"

        authenticator = passport.authenticate 'local', (err, user) ->
            if err
                console.log err
                res.send error: true, msg: "Server error occured.", 500
            else if user is undefined or not user
                console.log err if err
                res.send error: true, msg: "Wrong password", 400
            else
                req.logIn user, {}, answer

        req.body.username = "owner"
        authenticator(req, res)

    # Clear authentication credentials from session for current user.
    logoutAction: (req, res) =>
        req.logOut()
        passport.currentUser = null
        
        
        res.send
            success: true
            msg: "Log out succeeds."

    # Create user with given credentials
    registerAction: (req, res) =>
        email = req.body.email
        password = req.body.password

        createUser = (url) =>
            hash = passport_utils.cryptPassword password

            user =
                email: email
                owner: true
                password: hash.hash
                salt: hash.salt
                activated: true
                docType: "User"

            @dbClient.post "data/", user, (err, response, user) ->
                if err
                    console.log err
                    res.send error: true, msg: "Server error occured.", 500
                else if response.statusCode != 201
                    res.statusCode response.statusCode
                    res.send error: true, msg: "Server error occured.", 500
                else
                    req.logIn user, {}, ->
                        res.send success: true, msg: "Register succeeds."

        if password? and password.length > 4
            if passport_utils.checkMail email
                @dbClient.post "request/user/all/", {}, (err, res, users) =>
                    if err
                        console.log err
                        res.send error: true, msg: "Server error occured.", 500
                    else if users.length
                        res.send error: true, msg: "User already registered.", 400
                    else
                        createUser()
            else
                res.send error: true, msg: "Wrong email format", 400
        else
            res.send error: true, msg: "Password is too short", 400

    # Send an email with a temporary key that allows acceess to 
    # a change password page.
    forgotPasswordAction: (req, res) =>
        @dbClient.post "request/user/all/", {}, (err, resp, users) =>
            if err
                console.log err
                res.send error: true, msg: "Server error occured.", 500
            else if users.length == 0
                res.send
                    error: true
                    msg: "No user set, register first error occured.", 500
            else
                user = users[0].value
                key = passport_utils.genResetKey()
                @dbClient.post "request/cozyinstance/all/", {}, (err, resp, instances) =>
                    if err
                        console.log err
                        res.send error: true, msg: "Server error occured.", 500
                    else
                        if instances.length > 0
                            instance = instances[0].value
                        else
                            instance = domain: "domain.not.set"
                            passport_utils.sendResetEmail instance, user, key, (err, result) ->
                                console.log err if err
                                res.send success: true

    # Display reset password view, only if given key is valid.
    resetPasswordView: (req, res) =>
        passport_utils.checkKey req.params.key, (err, isKeyOk) ->
            if err
                console.log err
                res.send error: true, msg: "Server error occured.", 500
            else if isKeyOk
                res.render 'reset', resetKey: req.params.key
            else
                res.redirect '/'

    resetPasswordAction: (req, res) =>
        key = req.params.key
        newPassword = req.body.password

        checkKey = (user) ->
            passport_utils.checkKey key, (err, isKeyOk) ->
               if err
                   res.send error: true, msg: "Server error occured.", 500
               else if not isKeyOk
                   res.send error: true, msg: "Key is not valid.", 400
               else
                   changeUserData user

        changeUserData = (user) =>
            if newPassword? and newPassword.length > 5
                data =
                    password: passport_utils.cryptPassword newPassword
            
                
                @dbClient.put "data/merge/#{user._id}/", data, (err, resp) ->
                    if resp.statusCode == 404 or resp.statusCode == 500
                        res.send error: true, msg: 'User cannot be updated', 400
                    else
                        client = redis.createClient()

                        client.set "resetKey", "", ->
                            res.send success: true, msg: 'Password updated successfully'
            else
                res.send error: true, msg: 'Password is too short', 400

        @dbClient.post "request/user/all/", {}, (err, response, users) ->
            if err
                console.log err
                res.send error: true, msg: "Server error occured.", 500
            else if users.length == 0
                res.send error: true, msg: "No user registered.", 400
            else
                checkKey users[0].value

# Main function
if not module.parent
    router = new exports.CozyProxy()
    router.start()
    console.log "Proxy listen on port " + router.proxyPort
    console.log "Initializing routes..."
    router.resetRoutes (error) ->
        if error
            console.log error.message
            console.log "Routes initializing failed"
        else
            console.log "Routes initialized"
            for route of router.routes
                console.log "#{route} => #{router.routes[route]}"

