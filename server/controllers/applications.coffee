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

forwardRequest = (req, res, errTemplate, next) ->
    connectionClosed = false
    req.on 'close', -> connectionClosed = true
    res.on 'close', -> connectionClosed = true
    appName = req.params.name
    shouldStart = -1 is req.url.indexOf 'socket.io'
    appManager.ensureStarted appName, shouldStart, (err, result) ->
        if connectionClosed
            return
        else if err?
            error = new Error err.msg
            error.status = err.code
            error.template = errTemplate err
            next error
        else if result.type is 'static'
            getPathForStaticApp appName, req.url, result.path, (url) ->
                send(req, url).pipe res
        else
            getProxy().web req, res, target: "http://localhost:#{result.port}"

module.exports.app = (req, res, next) ->
    req.url = req.url.substring "/apps/#{appName}".length
    errTemplate = (err) ->
        name: if err.code is 404 then 'not_found' else 'error_app'
    forwardRequest req, res, errTemplate, next

module.exports.publicApp = (req, res, next) ->
    req.url = req.url.substring "/public/#{appName}".length
    req.url = "/public#{req.url}"
    errTemplate = (err) ->
        name: 'error_public'

module.exports.appWithSlash = (req, res) -> res.redirect "#{req.url}/"
