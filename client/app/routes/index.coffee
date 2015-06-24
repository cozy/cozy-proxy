RegisterLayout = require 'views/layouts/register_layout'

RegistrationModel = require 'models/registration'


module.exports = class Router extends Backbone.Router

    routes:
        'login':               'login'
        'password/reset/:key': 'resetPassword'
        'register?step=:step': 'register'
        'register':            'register'


    initialize: (options) ->
        @app = options.app


    login: ->
        console.debug 'login'


    resetPassword: (key) ->
        console.debug 'reset password', key


    register: (step) ->
        return @navigate 'register?step=preset', trigger: true unless step?

        currentView = @app.layout.getChildView 'content'

        if not currentView or not currentView instanceof RegisterLayout
            registration = new RegistrationModel()
            currentView  = new RegisterLayout model: registration
            @app.layout.showChildView 'content', currentView

        currentView.model.set 'step', step
