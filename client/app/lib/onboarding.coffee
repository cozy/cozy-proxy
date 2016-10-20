# Local class Step
class Step
    # Retrieves properties from config Step plain object
    # @param step : config step, i.e. plain object containing custom properties
    #   and methods.
    constructor: (step={}, user={}) ->
        [
          'name',
          'route',
          'view',
          'isActive',
          'fetchUser',
          'validate',
          'save',
          'error'
        ].forEach (property) =>
            if step[property]?
                @[property] = step[property]

        @fetchUser user


    # Map some user properties to current step object
    # @param user : JS object representing the user.
    # This method can be overriden by passing another fetchUser function
    # in constructor parameters
    fetchUser: (user={}) ->
        @username = user.username


    # Record handlers for 'completed' internal pseudo-event
    onCompleted: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @completedHandlers = @completedHandlers or []
        @completedHandlers.push callback


    onFailed: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @failedHandlers = @failedHandlers or []
        @failedHandlers.push callback


    # Trigger 'completed' pseudo-event
    # returnValue is from configStep.submit
    triggerCompleted: () ->
        if @completedHandlers
            @completedHandlers.forEach (handler) =>
                handler(@)


    triggerFailed: (error) ->
        if @failedHandlers
            @failedHandlers.forEach (handler) =>
            handler(@, error)


    triggerFailed: (error) ->
        if @failedHandlers
            @failedHandlers.forEach (handler) =>
            handler(@, error)


    # Returns true if the step has to be submitted by the user
    # This method returns true by default, but can be overriden
    # by config steps
    # @param user : plain JS object. Not used in this abstract default method
    #  but should be in overriding ones.
    isActive: (user) ->
        return true


    # Submit the step
    # This method should be overriden by step given as parameter to add
    # for example a validation step.
    # Maybe it should return a Promise or a call a callback couple
    # in the near future
    submit: (data={}) ->
        return @save data
        .then @handleSubmitSuccess, @handleSubmitError


    # Handler for error occuring during a submit()
    handleSubmitError: (error) =>
        @triggerFailed error


    # Handler for submit success
    handleSubmitSuccess: =>
        @triggerCompleted()


    # Save data
    # By default this method returns a resolved promise, but it can overriden
    # by specifying another save method in constructor parameters
    # @param data : JS object containing data to save
    save: (data={}) ->
        return Promise.resolve(data)


    # Success handler for save() call
    handleSaveSuccess: (data) =>
        return data


    # Error handler for save() call
    handleSaveError: (err) =>
        error = Object.values err.errors
        throw new Error error

    error: (err) ->
        @triggerFailed err


# Main class
# Onboarding is the component in charge of managing steps
module.exports = class Onboarding

    constructor: (user, steps, currentStepName) ->
        @initialize user, steps, currentStepName


    initialize: (user, steps, currentStepName) ->
        throw new Error 'Missing mandatory `steps` parameter' unless steps

        @user = user
        @steps = steps
            .reduce (activeSteps, step) =>
                stepModel = new Step step, user
                if stepModel.isActive user
                    activeSteps.push stepModel
                    stepModel.onCompleted @handleStepCompleted
                    stepModel.onFailed @handleStepError
                return activeSteps
            , []

        if currentStepName
            @currentStep = @getStepByName currentStepName
            if not @currentStep
                throw new Error 'Given current step does not exist in step list'


    # Records handler for 'stepChanged' pseudo-event, triggered when
    # the internal current step in onboarding has changed.
    onStepChanged: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @stepChangedHandlers = (@stepChangedHandlers or []).concat callback


    onStepFailed: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @stepFailedHandlers = (@stepFailedHandlers or []).concat callback


    onStepFailed: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @stepFailedHandlers = (@stepFailedHandlers or []).concat callback


    # Handler for 'stepSubmitted' pseudo-event, triggered by a step
    # when it has been successfully submitted
    # Maybe validation should be called here
    # Maybe we will return a Promise or call some callbacks in the future.
    handleStepCompleted: =>
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


    handleStepError: (step, err) =>
        @currentStep = step
        @currentError = err
        @triggerStepErrors step, err


    # Trigger a 'StapFailed' pseudo-event
    triggerStepErrors: (step, args...) =>
        @stepFailedHandlers?.forEach (handler) ->


    # Trigger a 'StapFailed' pseudo-event
    triggerStepErrors: (step, err) =>
        if @stepFailedHandlers
            @stepFailedHandlers.forEach (handler) ->
                handler step, err


    handleStepError: (step, err) =>
        @currentStep = step
        @currentError = err
        @triggerStepErrors step, err


    # Trigger a 'StapFailed' pseudo-event
    triggerStepErrors: (step, err) =>
        if @stepFailedHandlers
            @stepFailedHandlers.forEach (handler) ->
                handler step, err


    # Trigger a 'done' pseudo-event, corresponding to onboarding end.
    triggerDone: ()->
        throw new Error 'Not implemented yet'


    # Returns an internal step by its name.
    getStepByName: (stepName) ->
        return @steps.find (step) ->
            return step.name is stepName


    # Returns progression associated to the given step object
    # @param step Step which we want to know the related progression
    # returns the current index of the step, from 1 to length. 0 if the step
    # does not exist in the onboarding.
    getProgression: (step) ->
        return \
            current: @steps.indexOf(step)+1,
            total: @steps.length,
            labels: @steps.map (step) -> step.name


    # Returns next step for the given step. Useful for knowing wich route to
    # use in a link-to-next.
    getNextStep: (step) ->
        if not step
            throw new Error 'Mandatory parameter step is missing'

        stepIndex = @steps.indexOf step

        if stepIndex is -1
            throw new Error 'Given step missing in onboarding step list'

        nextStepIndex = stepIndex+1

        if nextStepIndex is @steps.length
            return null

        return @steps[nextStepIndex]


    getCurrentStep: () =>
        return @currentStep


# Step is exposed for test purposes only
module.exports.Step = Step
