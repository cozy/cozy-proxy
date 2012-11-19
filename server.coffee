{CozyProxy} = require './proxy'

process.on 'uncaughtException', (err) ->
    console.error err.message
    console.error err.stack

# Write on console all couples, routes/port.
displayRoutes = (error) ->
    if error
        console.log error.message
        console.log "Routes initializing failed"
    else
        console.log "Routes initialized"
        for route of router.routes
            console.log "#{route} => #{router.routes[route]}"

# Main function
if not module.parent
    router = new CozyProxy()
    router.start()
    console.log "Proxy listen on port " + router.proxyPort
    console.log "Initializing routes..."
    router.resetRoutes displayRoutes
