path = require 'path'

configurePassport = require './lib/passport_configurator'
router            = require './lib/router'
{initializeProxy} = require './lib/proxy'
localization      = require './lib/localization_manager'
Device            = require './models/device'


module.exports = (app, server, callback) ->

    # noop
    if not callback? then callback = ->

    # configure passport which handles authentication
    configurePassport()

    # Pass localization helpers to app.locals to access them in templates
    app.locals.t         = localization.t
    app.locals.getLocale = localization.getLocale

    # Try to get assets definitions from root (only valid in build, not on
    # watch mode)
    try
        assets = require(path.join __dirname, '../webpack-assets').main
    app.locals.assets = assets

    # initialize Proxy server
    initializeProxy app, server

    # initialize device authentication
    # reset (load) and display the routes
    Device.update ->
        router.reset ->
            router.displayRoutes ->
                callback app, server
