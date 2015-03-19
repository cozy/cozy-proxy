cozyInstance = require '../models/instance'
application = require '../models/application'
#for the moment this is a poc !

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
