appManager = require '../lib/app_manager'
{getProxy} = require '../lib/proxy'
send = require 'send'
lockedpath = require 'lockedpath'
logger = require('printit')
    date: false
    prefix: 'controllers:applications'

# get path to start a static app
getPathForStaticApp = (appName, path, root, callback) ->
    logger.info "Starting static app #{appName}"
    path += 'index.html' if path is '/' or path is '/public/'
    callback lockedpath(root).join path

module.exports.app = (req, res, next) ->
    appName = req.params.name
    req.url = req.url.substring "/apps/#{appName}".length
    shouldStart = -1 is req.url.indexOf 'socket.io'
    appManager.ensureStarted appName, shouldStart, (err, result) ->
        if err?
            error = new Error err.msg
            error.status = err.code
            error.template =
                name: if err.code is 404 then 'not_found' else 'error_app'
            next error
        else if result.port?
            getProxy().web req, res, target: "http://localhost:#{result.port}"
        else
            # showing private static app
            getPathForStaticApp appName, req.url, result.path, (url) ->
                send(req, url).pipe res


module.exports.publicApp = (req, res, next) ->
    appName = req.params.name
    req.url = req.url.substring "/public/#{appName}".length
    req.url = "/public#{req.url}"
    shouldStart = -1 is req.url.indexOf 'socket.io'
    appManager.ensureStarted appName, shouldStart, (err, result) ->
        if err?
            error = new Error err.msg
            error.status = err.code
            error.template =
                name: 'error_public'
            next error
        else if result.port?
            getProxy().web req, res, target: "http://localhost:#{result.port}"
        else
            # showing public static app
            getPathForStaticApp appName, req.url, result.path, (url) ->
                send(req, url).pipe res

module.exports.appWithSlash = (req, res) -> res.redirect "#{req.url}/"
