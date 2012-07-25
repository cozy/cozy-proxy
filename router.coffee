httpProxy = require('http-proxy')
http = require('http')
https = require('https')
fs = require('fs')

# Port on which proxy listens
proxyPort = 4000

# Default port where requests are redirected
defaultPort = 3000
# Routes for redirection depending on given path
routes =
    "/apps/notes": 8001

# HTTPS options
# Server.key and Server.cert should be regenerated for each installation
options = {}
#    https:
#        key: fs.readFileSync('/home/cozy/server.key', 'utf8'),
#        cert: fs.readFileSync('/home/cozy/server.crt', 'utf8')


# Proxy server that uses route table defined earlier
proxyServer = httpProxy.createServer options, (req, res, proxy) ->
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
