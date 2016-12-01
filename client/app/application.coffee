###
application

Main application that create a Mn.Application singleton and exposes it. Needs
router and app_layout view.
###

{Application} = require 'backbone.marionette'

Router    = require './routes'
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
        @router = new Router app: @
        # if onboarding, the pathname will be '/register*'
        @router.route \
            'register(/:step)',
            'register',
            @handleRegisterRoute


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

# Exports Application singleton instance
module.exports = new App()
