httpProxy = require('http-proxy')
http = require('http')

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
    routes:
        "/apps/notes": 8001
        "/apps/todos": 8002
        "/apps/mails": 8003

    controllers:
        "/routes/add": controllers.addRoute
        "/routes/del": controllers.delRoute
        "/routes": controllers.showRoutes
    
    # Return route matching request
    matchRoute: (req, routes, callback) ->
        for route of routes
            if req.url.match("^" + route)
                callback(route)
                break

    # Proxy server that uses route table defined earlier
    handleRequest: (req, res, proxy) =>
        port = @defaultPort
        @matchRoute req, @routes, (route) =>
            req.url = req.url.substring(route.length)
            port = @routes[route]

        isAction = false
        if port == @defaultPort
            @matchRoute req, @controllers, (route) =>
                isAction = true
                console.log route
                @controllers[route](@routes, req, res)

        @proxyController(req, res, proxy, port) if not isAction

    proxyController: (req, res, proxy, port) ->
        buffer = httpProxy.buffer(req)
        proxy.proxyRequest req, res,
            host: 'localhost'
            port: port
            buffer: buffer
    
    start: (port) ->
        @proxyPort = port if port

        if not @proxyServer
            @proxyServer = httpProxy.createServer @handleRequest
        @proxyServer.listen @proxyPort
        
    stop: ->
        @proxyServer.close()


if not module.parent
    router = new exports.CozyProxy()
    router.start()
    console.log "Proxy listen on port " + router.proxyPort



# Interesting links : 
# https://github.com/visionmedia/express/blob/master/lib/router/index.js
# https://github.com/centro/dcrp
