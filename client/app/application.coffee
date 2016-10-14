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

timezones = require './lib/timezones'


class App extends Application

    ###
    Sets application

    We instanciate root application components
    - router: we pass the app reference to it to easily get it without requiring
              application module later.
    - layout: the application layout view, rendered.
    ###
    initialize: ->
        steps = require './config/steps/all'
        @on 'start', =>

            user = {
                username: ENV.username,
                hasValidInfos: ENV.hasValidInfos
            }

            @onboarding = new Onboarding(user, steps, ENV.currentStep)
            @onboarding.onStepChanged (step) => @handleStepChanged(step)
            @onboarding.onStepFailed (step, err) => @handleStepFailed(step, err)

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
        @router.route \
            'register(/:step)',
            'register',
            @handleRegisterRoute


    # Internal handler called when the onboarding's internal step has just
    # changed.
    # @param step Step instance
    handleStepChanged: (step) =>
        @router.navigate step.route, trigger: true


    # Update view with error message
    # only if view is still displayed
    # otherwhise dispatch the error in console
    handleStepFailed: (step, err) ->
        if @onboarding.currentStep isnt step
            console.error err.stack
        else
            @showStep step, err


    # Handler for register route, display onboarding's current step
    handleRegisterRoute: =>
        # Load onboarding stylesheet
        AppStyles = require './styles/onboarding.styl'

        currentStep = @onboarding.getCurrentStep()
        @router.navigate currentStep.route
        @showStep(currentStep)


    # Load the view for the given step
    showStep: (step, err=null) ->
        StepView = require "./views/#{step.view}"
        nextStep = @onboarding.getNextStep step
        @layout.showChildView 'content',
            new StepView
                model: new StepModel step: step, next: nextStep
                error: err
                progression: new ProgressionModel \
                    @onboarding.getProgression step



# Exports Application singleton instance
module.exports = new App()
