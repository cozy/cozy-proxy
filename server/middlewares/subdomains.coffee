path = require 'path'
cozyInstance = require path.join __dirname, '../models/instance'
application = require path.join __dirname, '../models/application'

# This midleware compare the hostname of the request with the domain registered
# in cozyInstance. If domains aren't the same, it will check if an application
# has the request domain on his document, and rewrite the request to be
# correctly handled by the proxy.
# If there isn't an app with the domain registered, the middleware do nothing

module.exports = (req, res, next) ->
    if req.url.indexOf("socket.io") > -1
        #if is a socket route, remove /public at the beggining
        req.url = req.url.substring "/public".length

    cozyInstance.getDomain (err, domain)->
        unless domain
            return next()

        unless (domain is req.headers.host)

            #we remove the port, because is not registered on the document
            hostname = req.headers.host.split(':')[0]

            application.domainSlug hostname, (err, appSlug) ->
                unless (appSlug is "")
                    req.url = "/public/#{appSlug}#{req.url}"
                next()
        else
            next()
