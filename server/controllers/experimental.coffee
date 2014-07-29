# Return the host meta file
# support only JSON format
# @TODO : support xml
module.exports.webfingerHostMeta = (req, res) ->

    return res.send 404 unless req.params.ext is 'json'

    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Credentials', true
    res.header 'Access-Control-Allow-Methods', 'GET'

    host = 'https://' + req.get 'host'
    template = "#{host}/webfinger/json?resource={uri}"

    hostmeta = links:
        rel: 'lrdd'
        template: template

    res.send 200, hostmeta


# return the account file
# @TODO : let the user add more information here
# OpenID provider, public email, public tel, ...
module.exports.webfingerAccount = (req, res) ->

    if req.params.module is 'caldav' or req.params.module is 'carddav'
        res.redirect '/public/sync/'

    else if req.params.module is 'webfinger'

        host = 'https://' + req.get 'host'
        OAUTH_VERSION = 'http://tools.ietf.org/html/rfc6749#section-4.2'
        PROTOCOL_VERSION = 'draft-dejong-remotestorage-01'

        res.header 'Access-Control-Allow-Origin', '*'
        res.header 'Access-Control-Allow-Credentials', true
        res.header 'Access-Control-Allow-Methods', 'GET'

        accountInfo = links: []
        routes = require('router').getRoutes()
        if routes['remotestorage']

            link =
                href: "#{host}/public/remotestorage/storage"
                rel: 'remotestorage'
                type: PROTOCOL_VERSION
                properties:
                    'auth-method': OAUTH_VERSION
                    'auth-endpoint': "#{host}/apps/remotestorage/oauth/"

            link.properties[OAUTH_VERSION] = link.properties['auth-endpoint']

            accountInfo.links.push link

        return res.send 200, accountInfo

    else
        res.send 404
