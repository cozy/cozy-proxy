httpProxy = require 'http-proxy'
express = require 'express'
randomstring = require 'randomstring'
bcrypt = require 'bcrypt'
fs = require 'fs'
qs = require 'querystring'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
Client = require('request-json').JsonClient

helpers = require './helpers'
middlewares = require './middlewares'
PasswordKeys = require './lib/password_keys'
StatusChecker = require './lib/status'
UserManager = require('./models').UserManager
InstanceManager = require('./models').InstanceManager

passwordKeys = new PasswordKeys()

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
        @server = httpProxy.createServer @app
        @proxy = @server.proxy
        @proxy.source.port = 9104
        @userManager = new UserManager()
        @instanceManager = new InstanceManager()
        configurePassport @userManager

        @app.enable 'trust proxy'
        @app.set 'view engine', 'jade'
        @app.use express.static(__dirname + '/public')
        @app.use middlewares.selectiveBodyParser
        @app.use express.cookieParser randomstring.generate()
        @app.use express.session
            secret: randomstring.generate()
            cookie:
                maxAge: 30 * 86400 * 1000
        @app.use passport.initialize()
        @app.use passport.session()
        @configureLogs()
        @app.use (err, req, res, next) ->
            console.error err.stack
            sendError res, err.message

        @enableSocketRedirection()
        @setControllers()


    configureLogs: ->
        format = '
            \\n \\033[33;22m :date \\033[0m
            \\n \\033[37;1m :method \\033[0m \\033[30;1m :url \\033[0m
            \\n  >>> perform
            \\n  Send to client: :status
            \\n  <<<  [:response-time ms]'
        if process.env.NODE_ENV is "development"
            @app.use express.logger format
        else
            env = process.env.NODE_ENV
            fs.mkdirSync 'log' unless fs.existsSync './log'
            logFile = fs.createWriteStream "./log/#{env}.log", flags: 'w'
            @app.use express.logger
                stream: logFile
                format: format
            if env is "production"
                console.log = (text) ->
                    logFile.write(text + '\n')

                console.error = (text) ->
                    logFile.write(text + '\n')

    setControllers: ->
        @app.get "/routes", @showRoutesAction
        @app.get "/routes/reset", @resetRoutesAction

        @app.get '/register', @registerView
        @app.post '/register', @registerAction
        @app.get  /^\/login/, @loginView
        @app.post '/login', @loginAction
        @app.post '/login/forgot', @forgotPasswordAction
        @app.get '/password/reset/:key', @resetPasswordView
        @app.post '/password/reset/:key', @resetPasswordAction
        @app.get '/logout', @logoutAction
        @app.get '/authenticated', @authenticatedAction
        @app.get '/status', @statusAction
        @app.get '/.well-known/host-meta.?:ext', @webfingerHostMeta
        @app.get '/.well-known/webfinger', @webfingerAccount

        @app.all '/public/:name/*', @redirectPublicAppAction
        @app.all '/apps/:name/*', @redirectAppAction
        @app.get '/apps/:name*', @redirectWithSlash
        @app.all '/*', @defaultRedirectAction

    # Start proxy server listening.
    start: (port) ->
        @proxyPort = port if port
        @server.listen(process.env.PORT || @proxyPort)

    # Stop proxy server listening.
    stop: ->
        @server.close()

    ### helpers ###

    sendSuccess: (res, msg, code=200) ->
        res.send success: true, msg: msg, code

    sendError: (res, msg, code=500) ->
        res.send error: true, msg: msg, code

    ### Routes ###

    # enable websockets
    # this is safe with socket.io, if we want to use a plain Websockets server
    # for some apps, we should use passport here too
    # We extract the app's slug using express's router
    # However, the _router variable is "private"
    # and might break with a future version of express
    enableSocketRedirection: =>
        @server.on 'upgrade', (req, socket, head) =>
            if slug = @app._router.matchRequest(req).params.name
                req.url = req.url.replace "/apps/#{slug}", ''
                port = @routes[slug].port
            else
                port = @defaultPort

            if port
                @proxy.proxyWebSocketRequest req, socket, head,
                    host: 'localhost',
                    port: port
            else
                socket.end "HTTP/1.1 404 NOT FOUND \r\n" +
                           "Connection: close\r\n", 'ascii'

    # Default redirection send requests to home.
    defaultRedirectAction: (req, res) =>
        if req.isAuthenticated()
            buffer = httpProxy.buffer(req)
            @proxy.proxyRequest req, res,
                host: 'localhost'
                port: @defaultPort
                buffer: buffer
        else
            url = "/login#{req.url}"
            url += "?#{qs.stringify(req.query)}" if req.query.length
            res.redirect url

    # ensure an app is started
    # @arg slug the app slug
    # @arg cb(err, port) a callback
    #   err.code / err.msg
    ensureStarted: (slug, doStart, cb) =>
        if not @routes[slug]?
            cb code:404, msg:'app unknown'
            return

        switch @routes[slug].state
            when 'broken'       then cb code:500, msg:'app broken'
            when 'installing'   then cb code:404, msg:'app is still installing'
            when 'installed'    then cb null, @routes[slug].port
            when 'stopped'
                unless doStart
                    return code: 500, msg: 'wont start'

                @startApp slug, (err) =>
                    if err?
                        cb code: 500, msg: "cannot start app : #{err}"
                    else
                        cb null, @routes[slug].port
            else cb code: 500, msg: 'incorrect app state'

    # request home to start a new app
    startApp: (slug, cb) =>
        client = new Client "http://localhost:#{@defaultPort}/"
        client.post "api/applications/#{slug}/start", {}, (err, _, data) =>
            cb(err) if err?
            cb(data.msg) if data.error
            @routes[slug] = data.app
            cb(null)

    # so we can go to /apps/app (no slash)
    redirectWithSlash: (req, res) =>
        res.redirect req.url+'/'

    # Redirect application, redirect request depending on app name.
    redirectAppAction: (req, res) =>

        unless req.isAuthenticated()
            url = "/login#{req.url}"
            url += "?#{qs.stringify(req.query)}" if req.query.length
            return res.redirect url

        buffer = httpProxy.buffer(req)
        appName = req.params.name
        req.url = req.url.substring "/apps/#{appName}".length

        doStart = -1 is req.url.indexOf 'socket.io'

        @ensureStarted appName, doStart, (err, port) =>
            return res.send err.code, err.msg if err?
            @proxy.proxyRequest req, res,
                host: 'localhost'
                port: port
                buffer: buffer

    # Redirect public side of application, redirect request depening on app
    # name. As for now, do not autostart on public routes
    redirectPublicAppAction: (req, res) =>

        buffer = httpProxy.buffer(req)
        appName = req.params.name
        req.url = req.url.substring "/public/#{appName}".length
        req.url = "/public#{req.url}"

        doStart = -1 is req.url.indexOf 'socket.io'

        @ensureStarted appName, doStart, (err, port) =>
            return res.send err.code, err.msg if err?
            @proxy.proxyRequest req, res,
                host: 'localhost'
                port: port
                buffer: buffer

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
                    @routes[app.slug] = {}
                    @routes[app.slug].port = app.port if app.port?
                    @routes[app.slug].state = app.state if app.state?
                callback()
            catch err
                return callback err

    ### Authentication ###

    loginView: (req, res) =>
        @userManager.all (err, users) =>
            if users?.length > 0 and not err
                name = helpers.hideEmail users[0].value.email
                if name?
                    name = name.charAt(0).toUpperCase() + name.slice(1)
                res.render 'login', username: name
            else
                res.redirect 'register'

    registerView: (req, res) =>
        @userManager.all (err, users) ->
            if not users? or users.length is 0
                res.render 'register'
            else
                res.redirect 'login'

    authenticatedAction: (req, res) =>
        res.send success: req.isAuthenticated()

    # Check user credentials and keep user authentication through session.
    authenticate: (req, res) =>
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
                @sendError res, "Wrong password", 400
            else
                passwordKeys.initializeKeys req.body.password, (err) =>
                    if err
                        console.log err
                        @sendError res, "Keys aren't initialized", 500
                    else
                        req.logIn user, {}, answer

        authenticator req, res


    loginAction: (req, res) =>
        req.body.username = "owner"
        @authenticate req, res

    # Clear authentication credentials from session for current user.
    logoutAction: (req, res) =>
        passwordKeys.deleteKeys (err) =>
            if err
                success: false
            else
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
                    @authenticate(req, res)

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
            console.log "send email"
            if instances.length > 0
                instance = instances[0].value
            else
                instance = domain: "domain.not.set"


            helpers.sendResetEmail instance, user, key, (err, result) =>
                if err
                    console.log err
                    @sendError res, "Email cannot be sent"
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
                @resetKey = randomstring.generate()
                @instanceManager.all (err, instances) =>
                    if err
                        console.log err
                        @sendError res, "Server error occured.", 500
                    else
                        sendEmail instances, user, @resetKey

    # Display reset password view, only if given key is valid.
    resetPasswordView: (req, res) =>
        if @resetKey is req.params.key
            res.render 'reset', resetKey: req.params.key
        else
            res.redirect '/'

    # Check password validity, then change password, then clear reset key
    # from redis cache.
    resetPasswordAction: (req, res) =>
        key = req.params.key
        newPassword = req.body.password

        checkKey = (user) =>
            if @resetKey is req.params.key
                changeUserData user
            else
                @sendError res, "Key is not valid.", 400

        changeUserData = (user) =>
            if newPassword? and newPassword.length > 5
                data = password: helpers.cryptPassword(newPassword).hash

                @userManager.merge user, data, (err) =>
                    if err
                        @sendError res, 'User cannot be updated'
                    else
                        @resetKey = ""
                        passwordKeys.resetKeys (err) =>
                            if err
                                @sendError res, "Server error occured", 500
                            else
                                @sendSuccess res, "Password updated \
                                        successfully"
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

    # Returns the state of main Cozy modules (true means up and false means
    # down).
    statusAction: (req, res) ->
        statusChecker = new StatusChecker()
        statusChecker.checkAllStatus (err, status) ->
            if err then res.send 500
            else res.send status

    # Return the host meta file
    # support only JSON format
    # @TODO : support xml
    webfingerHostMeta: (req, res) =>
        return res.send 404 unless req.params.ext is 'json'

        res.header 'Access-Control-Allow-Origin', '*'
        res.header 'Access-Control-Allow-Credentials', true
        res.header 'Access-Control-Allow-Methods', 'GET'

        host = 'https://' + req.get 'host'
        template = "#{host}/webfinger/json?resource={uri}"

        hostmeta = links:
            rel: 'lrdd'
            template: template

        res.send hostmeta


    # return the account file
    # @TODO : let the user add more information here
    # OpenID provider, public email, public tel, ...
    webfingerAccount: (req, res) =>
        host = 'https://' + req.get 'host'
        OAUTH_VERSION = 'http://tools.ietf.org/html/rfc6749#section-4.2'
        PROTOCOL_VERSION = 'draft-dejong-remotestorage-01'

        res.header 'Access-Control-Allow-Origin', '*'
        res.header 'Access-Control-Allow-Credentials', true
        res.header 'Access-Control-Allow-Methods', 'GET'

        accountinfo = links: []

        if @routes['remote-storage']

            link =
                href: "#{host}/public/remotestorage/storage"
                rel: 'remotestorage'
                type: PROTOCOL_VERSION
                properties:
                    'auth-method': OAUTH_VERSION
                    'auth-endpoint': "#{host}/apps/remotestorage/oauth/"

            link.properties[OAUTH_VERSION] = link.properties['auth-endpoint']

            accountinfo.links.push link

        res.send accountinfo
