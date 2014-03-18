{getProxy} = require '../lib/proxy'
router = require '../lib/router'
statusChecker = require '../lib/status_checker'

module.exports.defaultRedirect = (req, res) ->
    homePort = process.env.DEFAULT_REDIRECT_PORT
    getProxy().web req, res, target: "http://localhost:#{homePort}"

module.exports.showRoutes = (req, res) -> res.send 200, router.getRoutes()

module.exports.resetRoutes = (req, res) ->
    router.reset (error) ->
        if error?
            next new Error error
        else
            res.send 200, success: true

module.exports.status = (req, res) ->
    statusChecker.checkAllStatus (err, status) ->
        if err then next new Error err
        else res.send status
