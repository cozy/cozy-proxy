###
application

Main application that create a Mn.Application singleton and exposes it. Needs
router and app_layout view.
###
_        = require 'underscore'
{Application} = require 'backbone.marionette'

AppLayout = require './views/app_layout'

Onboarding = require './lib/onboarding'
StepModel = require './models/step'
ProgressionModel = require './models/progression'

class App extends Application

    # URL for the redirection when the onboarding is finished
    endingRedirection: '/'
    accountsStepName: 'accounts'
    agreementStepName: 'agreement'

    ###
    Sets application

    We instanciate root application components
    - router: we pass the app reference to it to easily get it without requiring
              application module later.
    - layout: the application layout view, rendered.
    ###
    initialize: ->
        @on 'start', =>

            @initializeRouter()

            @layout = new AppLayout()
            @layout.render()

            # Use pushState because URIs do *not* rely on fragment (see
            # `server/controllers/routes.coffee` file)
            Backbone.history.start pushState: true if Backbone.history
            Object.freeze @ if typeof Object.freeze is 'function'


    # Initialize routes relative to onboarding step.
    # The idea is to configure the router externally as a "native"
    # Backbone Router
    initializeRouter: () =>
        @router = new Backbone.Router()
        # if onboarding, the pathname will be '/register*'
        @router.route \
            'register(/:step)',
            'register',
            @handleRegisterRoute

        @router.route \
            'login(?next=*path)',
            'login',
            @handleLogin
        @router.route \
            'login(/*path)',
            'login',
            @handleLogin
        @router.route \
            'password/reset/:key',
            'resetPassword',
            @handleResetPassword


    # Internal handler called when the onboarding's internal step has just
    # changed.
    # @param step Step instance
    handleStepChanged: (step) ->
        @showStep step


    # Internal handler called when the onboarding is finished
    handleTriggerDone: () ->
        window.location.replace @endingRedirection


    # Update view with error message
    # only if view is still displayed
    # otherwhise dispatch the error in console
    handleStepFailed: (step, err) ->
        if @onboarding.currentStep isnt step
            console.error err.stack
        else
            @showStep step, err.message


    # Initialize the onboarding component
    initializeOnboarding: ->
        steps = require './config/steps/all'

        user = {
            public_name: ENV.public_name
            hasValidInfos: ENV.hasValidInfos,
            apps: ENV.apps
        }

        onboarding = new Onboarding(user, steps, ENV.onboardedSteps)
        onboarding.onStepChanged (step) => @handleStepChanged(step)
        onboarding.onStepFailed (step, err) => @handleStepFailed(step, err)
        onboarding.onDone () => @handleTriggerDone()

        return onboarding


    # Handler for register route, display onboarding's current step
    handleRegisterRoute: =>
        @onboarding ?= @initializeOnboarding()

        # Load onboarding stylesheet
        AppStyles = require './styles/app.styl'

        currentStep = @onboarding.getCurrentStep()
        @router.navigate currentStep.route
        @onboarding.goToStep(currentStep)


    # Load the view for the given step
    showStep: (step, err=null) =>
        StepView = require "./views/#{step.view}"
        nextStep = @onboarding.getNextStep step
        next = nextStep?.route or @endingRedirection

        stepView = new StepView
            model: new StepModel step: step, next: next
            error: err
            progression: new ProgressionModel \
                @onboarding.getProgression step

        if step.name is @accountsStepName
            stepView.on 'browse:myaccounts', @handleBrowseMyAccounts

        if step.name is @agreementStepName and ENV.HIDE_STATS_AGREEMENT
            stepView.disableStatsAgreement()

        @layout.showChildView 'content', stepView


    # Handler when browse action is submited from the Accounts step view.
    # This handler show a dedicated view that encapsulate an iframe loading
    # MyAccounts application.
    handleBrowseMyAccounts: (stepModel) =>
        MyAccountsView = require './views/onboarding/my_accounts'
        view = new MyAccountsView
            model: stepModel
            myAccountsUrl: ENV.myAccountsUrl
        @layout.showChildView 'content', view

    ###
    login route

    `path` will be extracted from url:
    - the part after the `/login` (e.g. /login/foo/bar => /foo/bar)
    - a `next` query string parameter (the new and more cleaner way, see
    server/middlewares/authentication.coffee#L36)
    ###
    handleLogin: (path = '/') =>
        if window.location.hash
            path = window.location.hash
        @auth path,
            backend: '/login'
            type:    'login'


    handleResetPassword: (key) =>
        @auth '/login',
            backend: window.location.pathname
            type:    'reset'

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
        AppStyles = require './styles/app.styl'

        AuthView  = require './views/auth'
        AuthModel = require './states/auth'

        # The `next` state-model option contains the path where the app must
        # redirect after a successful login.
        auth = new AuthModel next: path
        @authView = new AuthView _.extend options, model: auth
        @authView.on 'password:request', @handlePasswordRequest

        @layout.showChildView 'content', @authView

        @initializeNotification()


    ###
    Password request

    Send a password request to the server
    ###
    handlePasswordRequest: () =>
        @notificationView.hide()
        @authView.emptyErrors()

        # Have a break to avoid quick glitch in UI
        displayTime = 1000

        @authView.disableForgot()
        window
            .fetch '/login/forgot', method: 'POST'
            .then \
                @delayed(@, @handlePasswordRequestSuccess, displayTime),
                @delayed(@, @handlePasswordRequestError, displayTime)


    handlePasswordRequestSuccess: (response) =>
        if response.status is 204
            @authView.enableForgot()
            @notifySuccess \
                title: 'reset password request success title',
                message: 'reset password request success message'
        else
            @handlePasswordRequestError response


    handlePasswordRequestError: (response) =>
        @authView.enableForgot()
        @authView.renderErrors 'reset password request error'


    initializeNotification: () ->
        NotificationView = require './views/notification'
        NotificationModel = require './models/notification'

        notificationModel = new NotificationModel notification
        @notificationView = new NotificationView model: notificationModel

        @layout.showChildView 'notification', @notificationView


    notifySuccess: (notification) ->
        @notificationView.show(notification)


    delayed: (context, fn, milliseconds) ->
        return () ->
            delayedArguments = arguments
            setTimeout () ->
                fn.apply context, delayedArguments
            , milliseconds

# Exports Application singleton instance
module.exports = new App()
