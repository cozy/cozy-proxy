CozyInstance = require '../models/instance'
router = require '../lib/router'

# Return the host meta file
# support only JSON format
# @TODO : support xml
module.exports.webfingerHostMeta = (req, res, next) ->

    return res.sendStatus 404 unless req.params.ext is 'json'

    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Credentials', true
    res.header 'Access-Control-Allow-Methods', 'GET'

    CozyInstance.first (err, instance) ->
        domain = instance?.domain or req.headers.host
        unless domain
            return next new Error "Cozy's domain has not been registered"
        template = "https://#{domain}/webfinger/json?resource={uri}"

        hostmeta = links:
            rel: 'lrdd'
            template: template

        res.status(200).send hostmeta


# return the account file
# @TODO : let the user add more information here
# OpenID provider, public email, public tel, ...
module.exports.webfingerAccount = (req, res, next) ->

    CozyInstance.first (err, instance) ->
        domain = instance?.domain or req.headers.host
        unless domain
            return next new Error "Cozy's domain has not been registered"
        host = "https://#{domain}"

        if req.params.module in ['caldav', 'carddav']
            routes = router.getRoutes()
            if routes['sync']?
                res.redirect "#{host}/public/sync/"
            else
                res.status(404).send 'Application Sync is not installed.'

        else if req.params.module is 'webfinger'

            OAUTH_VERSION = 'http://tools.ietf.org/html/rfc6749#section-4.2'
            PROTOCOL_VERSION = 'draft-dejong-remotestorage-01'

            res.header 'Access-Control-Allow-Origin', '*'
            res.header 'Access-Control-Allow-Credentials', true
            res.header 'Access-Control-Allow-Methods', 'GET'

            accountInfo = links: []
            routes = router.getRoutes()
            if routes['remotestorage']

                link =
                    href: "#{host}/public/remotestorage/storage"
                    rel: 'remotestorage'
                    type: PROTOCOL_VERSION
                    properties:
                        'auth-method': OAUTH_VERSION
                        'auth-endpoint': "#{host}/apps/remotestorage/oauth/"

                authEndPoint = link.properties['auth-endpoint']
                link.properties[OAUTH_VERSION] = authEndPoint

                accountInfo.links.push link

            return res.status(200).send accountInfo

        else
            res.sendStatus 404
