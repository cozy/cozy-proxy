httpProxy = require('http-proxy')
http = require('http')

{Client} = require './common/test/client'
controllers = require "./controllers"

process.on 'uncaughtException', (err) ->
    console.log err.message
    console.log err.stack

class exports.CozyProxy

    # Port on which proxy listens
    proxyPort: 4000

    # Default port where requests are redirected
    defaultPort: 3000

    # Routes for redirection depending on given path
    routes: {}

    # Controllers needed to configure the router dynamically through a 
    # REST API
    controllers:
        "/routes/add": controllers.addRoute
        "/routes/del": controllers.delRoute
        "/routes": controllers.showRoutes
    
    # Return route matching request
    _matchRoute: (req, routes, callback) ->
        for route of routes
            if req.url.match("^" + route)
                callback(route)
                break

    # Proxy server that uses route table defined earlier
    handleRequest: (req, res, proxy) =>
        port = @defaultPort
        @_matchRoute req, @routes, (route) =>
            req.url = req.url.substring(route.length)
            port = @routes[route]

        isAction = false
        if port == @defaultPort
            @_matchRoute req, @controllers, (route) =>
                isAction = true
                if process.env.NODE_ENV != "test"
                    console.log "#{req.method} #{route}"
                @controllers[route](@routes, req, res)

        @proxyController(req, res, proxy, port) if not isAction

    # Controller that proxies request to the given port.
    proxyController: (req, res, proxy, port) ->
        buffer = httpProxy.buffer(req)
        proxy.proxyRequest req, res,
            host: 'localhost'
            port: port
            buffer: buffer
    
    # Start proxy server listening.
    start: (port) ->
        @proxyPort = port if port

        if not @proxyServer
            @proxyServer = httpProxy.createServer @handleRequest
        @proxyServer.listen @proxyPort
        
    # Stop proxy server listening.
    stop: ->
        @proxyServer.close()

    # Clear routes then build them from Cozy Home data.
    resetRoutes: (callback) ->
        @routes = {}
        client = new Client("http://localhost:#{@defaultPort}/")
        client.get "api/applications/", (error, response, body) =>
            return callback(error) if error
            try
                apps = JSON.parse body
                for app in apps.rows
                    @routes["/apps/#{app.slug}"] = app.port if app.port?
                callback()
            catch err
                return callback err


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


# Interesting links : 
# https://github.com/visionmedia/express/blob/master/lib/router/index.js
# https://github.com/centro/dcrp
