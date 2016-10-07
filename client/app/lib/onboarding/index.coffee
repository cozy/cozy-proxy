# TODO: fournir un getter ici
# TODO: fournir un 2Nd oublet pour les actions
# TODO: séparer le state/store du getter!

# Local class Step
class State

    steps: [
        welcome = require './model/welcome',
        agreement = require './model/agreement',
        password = require './model/password',
        confirmation = require './model/confirmation',
    ]

    constructor: () ->
        @_index = 0;


    getCurrent: ->
        @steps[@_index]


    getNext: ->
        index = @_index + 1
        @steps[nextIndex]


    getPrevious: ->
        index = @_index - 1
        @steps[nextIndex]


    # Returns an internal step by its name.
    getIndexOfStep: (stepName) ->
        steps = @steps.map (step) -> return stepName
        steps.indexOf stepName


    # Save current data
    # and keep trace of previous stateIndex
    # enable state history navigation
    # such as stateMachine
    save: ({ index }) ->
        unless (nextState = @steps[index])?
            throw Error 'Current step cannot be found in steps list'

        if index isnt @_index
            @_previousIndex = @_index
            @_index = index

            # Listen to this event
            # to redirect to other views
            _trigger 'onboardingModel:change', {
                step: @getCurrent(),
                previous: @getPrevious()


# Main class
# StateController is the component in charge of managing steps
module.exports.StateController = class StateController

    constructor: (user={}) ->
        @user = user
        @state = new State()


    doValidate: (data) ->
        @state.getCurrent()?.validate data


    # Go to the next step in the list.
    # when submitting a form
    doSubmit: (data) ->
        if (model = @state.getCurrent().validate(data))
            # Select Next Step
            @state.save {index: @_index + 1}
            return true

        return false


    # Force step selection
    # ie. route cases
    doSelectStep: (name) ->
        if (index = @model.getIndexOfStep name) is -1
            throw new Error 'Step does not exist'
            return false

        @state.save {index}
        return true

    #
    # TODO: move this into
    # dedicated Getter object?
    #

    # Return Current View
    # related to current State
    getStepView: ->
        return require @state.view


    getState: ->
        return @state


_trigger = (name, data) ->
    event = new CustomEvent name, { detail: data }
    document.dispatchEvent event


_listenTo = (name, callback) ->
    document.addEventListener name, callback
