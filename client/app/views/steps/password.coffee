StepView = require '../step'
_ = require 'underscore'

module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click .next': 'doSubmit'
        'click [action=password-visibility]': 'doToggleVisibility'


    initialize: (args...) ->
        super args...

        @model.on 'change', @renderInput


    renderInput: =>
        {inputType, visibilityTxt, visibilityClassName} = @serializeInputData()

        @$('input[name=password]').attr 'type', inputType
        @$('[action=password-visibility] span').html t(visibilityTxt)
        @$('[action=password-visibility]').attr 'class', visibilityClassName


    # Get 1rst error only
    # err is an object such as:
    # {type: 'step empty fields', error: 'username' }
    #
    # Error can only come from:
    # user values or password value
    serializeData: () ->
        if (err = @errors)? and 'object' is typeof err
            err = err.shift() if err.length
            return { error: t(err.text, {name: err.error}) }
        else
            return {}


    # Get 1rst error only
    # err is an object such as:
    # { type: 'password', text:'step empty fields'}
    serializeData: () ->
        {
            error:      @error.message if @error
            stepName:   @model.get 'name'
            figureid:   require '../../assets/sprites/illustrate-password.svg'
        }


    # Get 1rst error only
    # err is an object such as:
    # {type: 'step empty fields', error: 'username' }
    #
    # Error can only come from:
    # user values or password value
    serializeData: () ->
        if (err = @errors)? and 'object' is typeof err
            err = err.shift() if err.length
            return { error: t(err.text, {name: err.error}) }
        else
            return {}


    serializeInputData: =>
        isVisible = @model.get('isVisible') or false
        visibilityAction = if isVisible then 'hide' else 'show'
        {
            visibilityClassName: "#{visibilityAction}-password"
            visibilityTxt: "step password #{visibilityAction}"
            inputType: if isVisible then 'text' else 'password'
        }


    doToggleVisibility: (event) ->
        event?.preventDefault()

        isVisible = @model.get('isVisible') or false
        @model.set { isVisible: not isVisible }


    getDataFromDOM: ->
        return {
            password: @$('input[name=password]').val()
            onboardedSteps: ['welcome', 'agreement', 'password']
        }


    doSubmit: (event)->
        event?.preventDefault()
        @model.submit @getDataFromDOM()
