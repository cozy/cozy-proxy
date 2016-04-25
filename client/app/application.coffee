###
application

Main application that create a Mn.Application singleton and exposes it. Needs
router and app_layout view.
###

require 'normalize.css/normalize.css'
require './styles/app.styl'

{Application} = require 'backbone.marionette'

Router    = require './routes'
AppLayout = require './views/app_layout'


class App extends Application

    ###
    Sets application

    We instanciate root application components
    - router: we pass the app reference to it to easily get it without requiring
              application module later.
    - layout: the application layout view, rendered.
    ###
    initialize: ->
        @on 'start', (options) =>
            @router = new Router app: @

            @layout = new AppLayout()
            @layout.render()

            # Use pushState because URIs do *not* rely on fragment (see
            # `server/controllers/routes.coffee` file)
            Backbone.history.start pushState: true if Backbone.history
            Object.freeze @ if typeof Object.freeze is 'function'


# Exports Application singleton instance
module.exports = new App()
