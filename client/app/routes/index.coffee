###
Main application Router

Handles routes exposed by the application. It generate views/viewModels couples
when needed and show them in the app_layout regions.
###

_        = require 'underscore'
Backbone = require 'backbone'

module.exports = class Router extends Backbone.Router

    routes:
        'login(?next=*path)':        'login'
        'login(/*path)':             'login'
        'password/reset/:key':       'resetPassword'
        'register(?step=:step)':     'register'


    ###
    Initialize stores the application reference for a later use inside the
    router.
    ###
    initialize: (options) ->
        @app = options.app


    ###
    Auth view generation

    Login and ResetPassword views are basically the same ones and uses the same
    logics. So they use the same view/state-model class and we switch the
    rendering mode at launch by passing a `type` option.

    View options also contains a `backend` url which is the endpoint called by
    the submitted form.
    ###
    auth: (path, options) ->
        AuthView  = require '../views/auth'
        AuthModel = require '../states/auth'

        # The `next` state-model option contains the path where the app must
        # redirect after a successful login.
        auth = new AuthModel next: path
        @app.layout.showChildView 'content', new AuthView _.extend options,
            model: auth


    ###
    login route

    `path` will be extracted from url:
    - the part after the `/login` (e.g. /login/foo/bar => /foo/bar)
    - a `next` query string parameter (the new and more cleaner way, see
    server/middlewares/authentication.coffee#L36)
    ###
    login: (path = '/') ->
        if window.location.hash
            path = window.location.hash
        @auth path,
            backend: '/login'
            type:    'login'


    resetPassword: (key) ->
        @auth '/login',
            backend: window.location.pathname
            type:    'reset'


    ###
    Register route

    Register views uses the same layout view and the step content is a subview
    component determined by the step param.
    ###
    register: (step = 'preset') -> require.ensure [], =>
        RegisterView      = require '../views/register'
        RegistrationModel = require '../states/registration'

        currentView = @app.layout.getChildView 'content'

        # Ensure the current view in the app layout is a RegisterView. If not,
        # then creates a new RegistrationModel state-machine and a RegisterView
        # and show it in the main AppLayout Region
        unless currentView? and currentView instanceof RegisterView
            registration = new RegistrationModel()
            # We assign the step property to the router's navigate method to
            # update the URL each time the step changes.
            registration.get('step')
                        .map (step) -> "register?step=#{step}" if step
                        .assign @, 'navigate'

            currentView  = new RegisterView model: registration
            @app.layout.showChildView 'content', currentView

        # When the RegisterView is render in the AppLayout, set its current
        # step (default to `preset`).
        currentView.model.setStep step
