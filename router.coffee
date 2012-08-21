httpProxy = require('http-proxy')
http = require('http')

process.on 'uncaughtException', (err) ->
    console.log err.message
    console.log err.stack


showRoutesController = (routes, req, res) =>
    res.writeHead(200, {'Content-Type': 'application/json'})
    res.end(JSON.stringify routes)

class CozyProxy

    # Port on which proxy listens
    proxyPort: 4000

    # Default port where requests are redirected
    defaultPort: 3000

    # Routes for redirection depending on given path
    routes:
        "/apps/notes": 8001
        "/apps/todos": 8002
        "/apps/mails": 8003

    controllers: (=>
        "/routes/add": (req, res) ->
        "/routes/del": (req, res) ->
        "/routes": showRoutesController
    )()

    # Return route matching request
    matchRoute: (req, routes, callback) ->
        for route of routes
            callback(route) if req.url.match("^" + route)

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
                @controllers[route](@routes, req, res)

        @proxyController(req, res, proxy, port) if not isAction

    proxyController: (req, res, proxy, port) ->
        buffer = httpProxy.buffer(req)
        proxy.proxyRequest req, res,
            host: 'localhost'
            port: port
            buffer: buffer
    
    start: ->
        if not @proxyServer
            @proxyServer = httpProxy.createServer @handleRequest
        @proxyServer.listen @proxyPort
        console.log "Proxy listen on port " + @proxyPort
        
    stop: ->
        @proxyServer.close()


router = new CozyProxy()
router.start()



# Interesting links : 
# https://github.com/visionmedia/express/blob/master/lib/router/index.js
# https://github.com/centro/dcrp
