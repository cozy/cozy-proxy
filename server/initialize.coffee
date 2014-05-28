configurePassport = require './lib/passport_configurator'
router = require './lib/router'
feed = require './lib/feed'
{initializeProxy} = require './lib/proxy'
localization = require './lib/localization_manager'
Device = require './models/device'

module.exports = (app, server, callback) ->

    # noop
    if not callback? then callback = ->

    # configure passport which handles authentication
    configurePassport()

    # initialize Proxy server
    initializeProxy app, server

    # initialize feed
    feed.initialize server
    
    # initialize device authentication
    # reset (load) and display the routes
    Device.update -> router.reset -> router.displayRoutes ->

        # cache the localization object
        localization.initialize -> callback app, server