appManager = require '../lib/app_manager'
{getProxy} = require '../lib/proxy'


module.exports.app = (req, res, next) ->
    appName = req.params.name
    req.url = req.url.substring "/apps/#{appName}".length
    shouldStart = -1 is req.url.indexOf 'socket.io'
    appManager.ensureStarted appName, shouldStart, (err, port) ->
        if err?
            error = new Error err.msg
            error.status = err.code
            error.template =
                name: if err.code is 404 then 'not_found' else 'error_app'
            next error
        else
            getProxy().web req, res, target: "http://localhost:#{port}"

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
            next error
        else
            getProxy().web req, res, target: "http://localhost:#{port}"

module.exports.appWithSlash = (req, res) -> res.redirect "#{req.url}/"
