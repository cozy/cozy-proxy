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
        # Load app stylesheet
        AppStyles = require '../styles/app.styl'

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
