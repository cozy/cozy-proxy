
class State

    constructor: ({steps, actions}) ->
        unless steps
            throw new Error 'Missing mandatory `steps` parameter'

        @steps = steps or []
        @actions = actions or {}

        # Initialize
        @value = @steps[0]


    trigger: (name, [current, previous]) ->
        # Global action
        console.info '(event)', name, data

        # Specific action
        if name is 'change' and (callback = @actions['change'])
            callback current, previous


    getCurrent: ->
        return @value


    getNext: ->
        index = @steps.indexOf @value
        return @steps[++index]


    getPrevious: ->
        index = @steps.indexOf @value
        return @steps[--index]


    getIndexOfStep: (name) ->
        index = -1
        @steps.find (step, i) ->
            if (name is step.name)
                index = i
                return true

        if -1 is index
            throw new Error 'Step does not exist'

        return index


    # Save current data
    # and keep trace of previous stateIndex
    # enable state history navigation
    # such as stateMachine
    save: (model) ->
        if model isnt @value
            @previousValue = @value
            @value = model

            # Listen to this event
            # to redirect to other views
            @trigger 'change', [@getCurrent(), @getPrevious()]


# Main class
# StateController is the component in charge of managing steps
module.exports.StateController = class StateController

    constructor: ({ user, actions, steps }) ->
        @user = user
        @state = new State {steps, actions}


    doValidate: (data) ->
        @state.getCurrent()?.validate data


    # Go to the next step in the list.
    # when submitting a form
    doSubmit: (data) ->
        if (model = @state.getCurrent().validate(data))
            # Select Next Step
            @state.save model
            return true

        return false


    # Force step selection
    # ie. route cases
    doSelectStep: (name) ->
        try {
          index = @model.getIndexOfStep name
          @state.save {index}
        } catch e {
          console.error(e)
        }

    #
    # TODO: move this into
    # dedicated Getter object?
    #

    # Return Current View
    # related to current State
    getStepView: ->
        step = @state.value
        return require step.view


    getState: ->
        return @state.value


    getAllSteps: ->
        return @state.steps
