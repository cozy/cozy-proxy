appManager = require '../lib/app_manager'
{getProxy} = require '../lib/proxy'
urlHelper = require 'cozy-url-sdk'
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
    appName = req.params.name
    urlHelperSlug = appName.replace 'data-system', 'dataSystem'
    appSchema = 'http'
    appHost = 'localhost'
    if urlHelper[urlHelperSlug]
        appSchema = urlHelper[urlHelperSlug].schema()
        appHost = urlHelper[urlHelperSlug].host()
    shouldStart = -1 is req.url.indexOf 'socket.io'
    appManager.ensureStarted appName, shouldStart, (err, result) ->
        if not res.connection or res.connection.destroyed
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
            url = "#{appSchema}://#{appHost}:#{result.port}"
            getProxy().web req, res, target: url

module.exports.app = (req, res, next) ->
    appName = req.params.name
    req.url = req.url.substring "/apps/#{appName}".length
    errTemplate = (err) ->
        name: if err.code is 404 then 'not_found' else 'error_app'
    forwardRequest req, res, errTemplate, next

module.exports.publicApp = (req, res, next) ->
    appName = req.params.name
    req.url = req.url.substring "/public/#{appName}".length
    req.url = "/public#{req.url}"
    errTemplate = (err) ->
        name: 'error_public'
    forwardRequest req, res, errTemplate, next

module.exports.appWithSlash = (req, res) -> res.redirect "#{req.url}/"
