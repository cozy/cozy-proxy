# Local class Step
class Step
    # Retrieves properties from config Step plain object
    constructor: (step={}) ->
        @validatedHandlers = []

        ['name', 'route', 'view'].forEach (property) =>
            @[property] = step[property]



    # Record handlers for 'validated' internal pseudo-event
    onValidated: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @validatedHandlers = @validatedHandlers or []
        @validatedHandlers.push callback


    # Trigger 'validated' pseudo-event
    triggerValidated: () ->
        if @validatedHandlers
            @validatedHandlers.forEach (handler) =>
                handler(@)


    # Submit the step
    # This method should be overriden by step given as parameter to add
    # for example a validation step.
    # Maybe it should return a Promise or a call a callback couple
    # in the near future
    submit: () ->
        @triggerValidated()


# Main class
# Onboarding is the component in charge of managing steps
module.exports = class Onboarding


    constructor: (user, steps) ->
        @initialize user, steps


    initialize: (user, steps) ->
        throw new Error 'Missing mandatory `steps` parameter' unless steps

        @user = user
        @steps = steps.map (step) =>
            stepModel = new Step step
            stepModel.onValidated () =>
                @handleStepSubmitted()
            return stepModel


    # Records handler for 'stepChanged' pseudo-event, triggered when
    # the internal current step in onboarding has changed.
    onStepChanged: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @stepChangedHandlers = @stepChangedHandlers or []
        @stepChangedHandlers.push callback


    # Handler for 'stepSubmitted' pseudo-event, triggered by a step
    # when it has been successfully submitted
    # Maybe validation should be called here
    # Maybe we will return a Promise or call some callbacks in the future.
    handleStepSubmitted: () ->
        @goToNext()


    # Go to the next step in the list.
    goToNext: () ->
        currentIndex = @steps.indexOf(@currentStep)

        if @currentStep? and currentIndex is -1
            throw Error 'Current step cannot be found in steps list'

        # handle magically the case not @currentStep and currentIndex is -1.
        nextIndex = currentIndex+1

        if @steps[nextIndex]
            @goToStep @steps[nextIndex]
        else
            @triggerDone()


    # Go directly to a given step.
    goToStep: (step) ->
        @currentStep = step
        @triggerStepChanged step


    # Trigger a 'StepChanged' pseudo-event.
    triggerStepChanged: (step) ->
        if @stepChangedHandlers
            @stepChangedHandlers.forEach (handler) ->
                handler step


    # Trigger a 'done' pseudo-event, corresponding to onboarding end.
    triggerDone: ()->
        throw 'Not implemented yet';


    # Returns an internal step by its name.
    getStepByName: (stepName) ->
        return @steps.find (step) ->
            return step.name is stepName

# Step is exposed for test purposes only
module.exports.Step = Step
