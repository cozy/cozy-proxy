Router    = require 'routes'
AppLayout = require 'views/app_layout'


class Application extends Backbone.Marionette.Application

    initialize: ->
        @on 'start', (options) =>
            @router = new Router app: @

            @layout = new AppLayout()
            @layout.render()

            # Use pushState because URIs do *not* rely on fragment (see
            # `server/controllers/routes.coffee` file)
            Backbone.history.start pushState: true if Backbone.history
            Object.freeze @ if typeof Object.freeze is 'function'


module.exports = application = new Application()
