
# Add a route to proxy routes if given request is correct. 
exports.addRoute = (router, req, res) ->
    routes = router.routes
    body = ""
    req.on 'data', (chunk) ->
        body += chunk
    req.on 'end', ->
        routeInfos = JSON.parse body
        if not routeInfos.route? or not routeInfos.port?
            if process.env.NODE_ENV != "test"
                console.log "Wrong data were sent, route cannot be added"
            res.statusCode = 400
            res.setHeader 'Content-Type', 'application/json'
            res.end()
        else
            routes[routeInfos.route] = routeInfos.port
            if process.env.NODE_ENV != "test"
                console.log "New route added #{routeInfos.route} redirect " + \
                            "to port #{routeInfos.port}"
            res.statusCode = 201
            res.setHeader 'Content-Type', 'application/json'
            res.end("")

# Remove a route that is given in parameter.
exports.delRoute = (router, req, res) ->
    routes = router.routes
    body = ""
    req.on 'data', (chunk) ->
        body += chunk
    req.on 'end', ->
        routeInfos = JSON.parse body
        if not routeInfos.route?
            res.statusCode = 400
            res.setHeader 'Content-Type', 'application/json'
            res.end()
        else
            delete routes[routeInfos.route]
            if process.env.NODE_ENV != "test"
                console.log "Route removed : #{routeInfos.route}"
            res.statusCode = 204
            res.setHeader 'Content-Type', 'application/json'
            res.end()


# Controllers that returns all branches
exports.showRoutes = (router, req, res) ->
    routes = router.routes
    res.writeHead 200, {'Content-Type': 'application/json'}
    res.end JSON.stringify(routes)


# Reset controller routes by grabbing routes data from home application
exports.resetRoutes = (router, req, res) ->
    router.resetRoutes (error) ->
        if error
            res.writeHead 500, {'Content-Type': 'application/json'}
            res.end JSON.stringify error
        else
            res.statusCode = 200
            res.end()

