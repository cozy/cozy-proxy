appManager = require '../lib/app_manager'
{getProxy} = require '../lib/proxy'
localization = require '../lib/localization_manager'
feed = require '../lib/feed'

module.exports.app = (req, res, next) ->
    end = false

    publishUsage = (appName) =>
        if not end
            setTimeout () =>
                if not end
                    feed.publish 'usage.application', appName
                    publishUsage(appName)
            , 60000

    appName = req.params.name
    req.url = req.url.substring "/apps/#{appName}".length
    shouldStart = -1 is req.url.indexOf 'socket.io'
    appManager.ensureStarted appName, shouldStart, (err, port) ->
        if err?
            error = new Error err.msg
            error.status = err.code
            error.template =
                name: if err.code is 404 then 'not_found' else 'error_app'
                params: polyglot: localization.getPolyglot()
            next error
        else
            getProxy().web req, res, target: "http://localhost:#{port}"
            req.on 'end', () ->
                end = true
            publishUsage appName


module.exports.publicApp = (req, res, next) ->
    appName = req.params.name
    req.url = req.url.substring "/public/#{appName}".length
    req.url = "/public#{req.url}"

    shouldStart = -1 is req.url.indexOf 'socket.io'
    appManager.ensureStarted appName, shouldStart, (err, port) ->
        if err?
            error = new Error err.msg
            error.status = err.code
            error.template =
                name: 'error_public'
                params: polyglot: localization.getPolyglot()
            next error
        else
            getProxy().web req, res, target: "http://localhost:#{port}"

module.exports.appWithSlash = (req, res) -> res.redirect "#{req.url}/"
