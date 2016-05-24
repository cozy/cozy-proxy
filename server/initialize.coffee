path = require 'path'

configurePassport = require './lib/passport_configurator'
router            = require './lib/router'
{initializeProxy} = require './lib/proxy'
localization      = require './lib/localization_manager'
remoteAccess      = require './lib/remote_access'
axon              = require 'axon'


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
    catch
        assets =
            js: 'app.js'
            css: 'app.css'
    app.locals.assets = assets

    # initialize Proxy server
    initializeProxy app, server


    socket = axon.socket 'sub-emitter'
    socket.connect 9105
    socket.on 'device.*', -> remoteAccess.updateCredentials()


    # initialize device authentication
    # reset (load) and display the routes

    remoteAccess.updateCredentials () ->
        router.reset ->
            router.displayRoutes ->
                callback app, server
