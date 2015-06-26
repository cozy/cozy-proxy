RegisterView = require 'views/register'

RegistrationModel = require 'states/registration'


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

        unless currentView? and currentView instanceof RegisterView
            registration = new RegistrationModel()
            registration.get('step').onValue (step) =>
                @navigate "register?step=#{step}"

            currentView  = new RegisterView model: registration
            @app.layout.showChildView 'content', currentView

        currentView.model.setStep step
