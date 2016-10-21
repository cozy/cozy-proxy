StepView = require '../step'
passwordHelper = require '../../lib/password_helper'


module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click .next': 'onSubmit'
        'click [action=password-visibility]': 'onToggleVisibility'
        'keyup input': 'checkPasswordStrength'


    isVisible: false


    onRender: ->
        @$inputPassword = @$('input[name=password]')
        @$visibilityButton = @$('[action=password-visibility]')
        @$visibilityIcon = @$('.icon use')


    renderInput: =>
        data = @serializeInputData()

        # Show/hide password value
        @$inputPassword.attr 'type', data.inputType

        # Update Button title
        @$visibilityButton.attr 'title', t(data.visibilityTxt)

        # Update Button Icon
        @$visibilityIcon.attr 'xlink:href', data.visibilityIcon

    initialize: (args...) ->
        super args...
        @passwordStrength = 0
        @updatePasswordStrength = updatePasswordStrength.bind(@)

    updatePasswordStrength= ->
        password = @$('input[name=password]').val()
        @passwordStrength = passwordHelper.getComplexityPercentage password
        @$('progress').attr 'value', @passwordStrength
        if @passwordStrength <= 33
            @$('progress').attr 'class', 'pw-weak'
        else if @passwordStrength > 33 and @passwordStrength <= 66
            @$('progress').attr 'class', 'pw-average'
        else
            @$('progress').attr 'class', 'pw-strong'

    # Get 1rst error only
    # err is an object such as:
    # { type: 'password', text:'step empty fields'}
    serializeData: () ->
        return Object.assign {}, @serializeInputData(), {
            error:      @error.message if @error
            id:         "#{@model.get 'name'}-figure"
            figureid:   require '../../assets/sprites/icon-lock.svg'
        }

    checkPasswordStrength: ->
        _.throttle(@updatePasswordStrength, 2000)()

    serializeInputData: =>
        visibilityAction = if @isVisible then 'hide' else 'show'
        iconState = if @isVisible then 'closed' else 'open'
        icon = require "../../assets/sprites/icon-eye-#{iconState}.svg"
        type = if @isVisible then 'text' else 'password'
        {
            visibilityTxt:  "step password #{visibilityAction}"
            visibilityIcon: icon
            inputType:      type
        }


    onToggleVisibility: (event) ->
        event?.preventDefault()

        # Update Visibility
        @isVisible = not @isVisible

        # Update Component
        @renderInput()


    getDataFromDOM: ->
        return {
            password: @$('input[name=password]').val()
            onboardedSteps: ['welcome', 'agreement', 'password']
        }

    serializeData: ->
        {
            passwordStrength: @passwordStrength
        }


    onSubmit: (event)->
        event?.preventDefault()
        isPasswordWeak = @passwordStrength <= 33
        if isPasswordWeak
            return false
        else
            @model.submit @getDataFromDOM()
