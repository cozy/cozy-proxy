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
        @on 'start', (options) =>

            @onboarding = new Onboarding({}, steps)
            @onboarding.onStepChanged (step) => @handleStepChanged(step)

            @initializeRouter @onboarding.steps

            @layout = new AppLayout()
            @layout.render()

            # Use pushState because URIs do *not* rely on fragment (see
            # `server/controllers/routes.coffee` file)
            Backbone.history.start pushState: true if Backbone.history
            Object.freeze @ if typeof Object.freeze is 'function'


    # Initialize routes relative to onboarding step.
    # The idea is to configure the router externally as a "native"
    # Backbone Router
    # @param steps a list of Step instance
    initializeRouter: (steps) =>
        @router = new Router app: @
        @router.route \
            'register(?step=:step)',
            'register',
            (step) => @handleStepRoute(step)

        steps.forEach (step) => @initializeStepRoute step


    # Initialize one route only
    # @param router Backbone.Router instance
    # @param step Step instance
    initializeStepRoute: (step) =>
        StepView = require "./views/#{step.view}"
        @router.route "#{step.route}", "route:#{step.route}", () =>
            @layout.showChildView 'content',
                new StepView
                    model: new StepModel step: step


    # Internal handler called when the onboarding's internal step has just
    # changed.
    # @param step Step instance
    handleStepChanged: (step) ->
        @router.navigate step.route, trigger: true


    # Register is the default main route for Onboarding
    handleStepRoute: (stepName='preset') ->
        # Load onboarding stylesheet
        AppStyles = require './styles/onboarding.styl'

        step = @onboarding.getStepByName stepName
        throw new Error 'Step does not exist' unless step
        @onboarding.goToStep @onboarding.getStepByName stepName


# Exports Application singleton instance
module.exports = new App()
