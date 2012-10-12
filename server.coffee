httpProxy = require('http-proxy')
express = require('express')


Client = require('request-json').JsonClient

process.on 'uncaughtException', (err) ->
    console.error err.message
    console.error err.stack

mime = (req) ->
  str = req.headers['content-type'] || ''
  return str.split(';')[0]

selectiveBodyParser = (req, res, next) ->
    if req.url.indexOf("/routes") != 0
            next()
        else
           # check Content-Type
            return next()  unless "application/json" is mime(req)

            # flag as parsed
            req._body = true

            # parse
            buf = ""
            req.setEncoding "utf8"
            req.on "data", (chunk) ->
                buf += chunk
            req.on "end", ->
                if "{" isnt buf[0] and "[" isnt buf[0]
                    return next(new Error("invalid json"))
                try
                    console.log "parsed"
                    
                    req.body = JSON.parse(buf)
                    next()
                catch err
                    err.body = buf
                    err.status = 400
                    next err


class exports.CozyProxy

    # Port on which proxy listens
    proxyPort: 4000

    # Default port where requests are redirected
    defaultPort: 3000

    # Routes for redirection depending on given path
    routes: {}

    constructor: ->
        @app = express()
        @proxy = new httpProxy.RoutingProxy()
        @app.use selectiveBodyParser
        
        @setControllers()

    # Controllers needed to configure the router dynamically through a 
    # REST API
    setControllers: ->
        @app.post "/routes", @addRouteAction
        @app.delete "/routes/:name", @delRouteAction
        @app.get "/routes", @showRoutesAction
        @app.get "/routes/reset", @resetRouteAction
        @app.all "/apps/:name/*", @redirectAppAction
        @app.all "/*", @defaultRedirectAction
        
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
        buffer = httpProxy.buffer(req)
        @proxy.proxyRequest req, res,
            host: 'localhost'
            port: @defaultPort
            buffer: buffer

    # Redirect application, redirect request depening on app name.
    redirectAppAction: (req, res) =>
        console.log "youpi!"
        
        buffer = httpProxy.buffer(req)
        appName = req.params.name
        req.url = req.url.substring "/apps/#{appName}".length
        
        port = @routes[appName]
        console.log port
        console.log appName
        console.log req.url
        
        if port?
            @proxy.proxyRequest req, res,
                host: 'localhost'
                port: @routes[req.params.name]
                buffer: buffer
        else
            res.send 404
            
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

