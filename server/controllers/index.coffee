{getProxy} = require '../lib/proxy'
router = require '../lib/router'
statusChecker = require '../lib/status_checker'
urlHelper = require 'cozy-url-sdk'

module.exports.defaultRedirect = (req, res) ->
    getProxy().web req, res, target: urlHelper.home.url()

module.exports.showRoutes = (req, res) ->
    res.status(200).send router.getRoutes()

module.exports.resetRoutes = (req, res, next) ->
    router.reset (error) ->
        if error?
            next new Error error
        else
            res.status(200).send success: true

module.exports.status = (req, res, next) ->
    statusChecker.checkAllStatus (err, status) ->
        if err then next new Error err
        else res.send status
