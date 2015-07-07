RegisterView = require 'views/register'
AuthView    = require 'views/auth'

RegistrationModel = require 'states/registration'
AuthModel        = require 'states/auth'


module.exports = class Router extends Backbone.Router

    routes:
        'login(*path)(?next=*path)':    'login'
        'password/reset/:key':   'resetPassword'
        'register(?step=:step)': 'register'


    initialize: (options) ->
        @app = options.app


    auth: (path, options) ->
        auth = new AuthModel next: path
        @app.layout.showChildView 'content', new AuthView _.extend options,
            model: auth


    login: (path) ->
        path ?= '/'
        @auth path,
            backend: '/login'
            type:    'login'


    resetPassword: (key) ->
        @auth '/login',
            backend: window.location.pathname
            type:    'reset'


    register: (step = 'preset') ->
        currentView = @app.layout.getChildView 'content'

        unless currentView? and currentView instanceof RegisterView
            registration = new RegistrationModel()
            registration.get('step')
                        .map (step) -> "register?step=#{step}" if step
                        .assign @, 'navigate'

            currentView  = new RegisterView model: registration
            @app.layout.showChildView 'content', currentView

        currentView.model.setStep step
