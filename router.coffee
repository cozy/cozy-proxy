httpProxy = require('http-proxy')
http = require('http')


# Port on which proxy listens
proxyPort = 80

# Default port where requests are redirected
defaultPort = 3000
# Routes for redirection depending on given path
routes =
    "/apps/noty-plus": 8001


# Return port corresponding to given path, returns defaultPort if no
# route corresponds.
getPort = (path) ->
    for route of routes
        if path.match("^" + route)
            return routes[route]
    defaultPort


# Proxy server that uses route table defined earlier
proxyServer = httpProxy.createServer (req, res, proxy) ->
    buffer = httpProxy.buffer(req)

    port = defaultPort
    for route of routes
        if req.url.match("^" + route)
            req.url = req.url.substring(route.length)
            port = routes[route]

    proxy.proxyRequest req, res,
        host: 'localhost'
        port: port
        buffer: buffer

# Start proxy server
proxyServer.listen proxyPort
console.log "Proxy listen on port " + proxyPort


# Interesting link : 
# https://github.com/centro/dcrp
