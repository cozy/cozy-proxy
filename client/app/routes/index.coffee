RegisterView = require 'views/register'
LoginView    = require 'views/login'

RegistrationModel = require 'states/registration'
LoginModel        = require 'states/login'


module.exports = class Router extends Backbone.Router

    routes:
        'login(?next=*path)':    'login'
        'password/reset/:key':   'resetPassword'
        'register(?step=:step)': 'register'


    initialize: (options) ->
        @app = options.app


    login: (path)->
        login = new LoginModel()
        @app.layout.showChildView 'content', new LoginView
            model: login
            next: path


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
