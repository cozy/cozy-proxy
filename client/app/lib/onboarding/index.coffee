
class State

    constructor: (actions) ->
        # TODO: naviguer par l'URI et non par l'index
        @value = @steps[0]

        @actions = actions


    trigger: (name, data) ->
        # Global action
        console.info '(event)', name, data

        # Specific action
        if name is 'change' and (callback = @actions['change'])
            callback data


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
            @trigger 'change', {
                step: @getCurrent(),
                previous: @getPrevious()
            }


# Main class
# StateController is the component in charge of managing steps
module.exports.StateController = class StateController

    constructor: ({ user, actions }) ->
        @user = user
        @state = new State actions


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
