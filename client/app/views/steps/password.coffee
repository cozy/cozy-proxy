StepView = require '../step'
passwordHelper = require '../../lib/password_helper'
_ = require 'underscore'


module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click .next': 'onSubmit'
        'click [action=password-visibility]': 'onToggleVisibility'
        'keyup input': 'checkPasswordStrength'


    isVisible: false


    onRender: (args...) ->
        super args...
        @$inputPassword = @$('input[name=password]')
        @$visibilityButton = @$('[action=password-visibility]')
        @$visibilityIcon = @$('.icon use')
        @$strengthBar = @$('progress')


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
        # lowest level is 1 to display a red little part
        @passwordStrength = {percentage: 1, label: 'weak'}
        @updatePasswordStrength = updatePasswordStrength.bind(@)

    updatePasswordStrength= ->
        password = @$('input[name=password]').val()
        @passwordStrength = passwordHelper.getStrength password

        if @passwordStrength.percentage is 0
             @passwordStrength.percentage = 1
        @$('progress').attr 'value', @passwordStrength.percentage
        @$('progress').attr 'class', 'pw-' + @passwordStrength.label

    initialize: (args...) ->
        super args...
        # lowest level is 1 to display a red little part
        @passwordStrength = passwordHelper.getStrength ''
        @updatePasswordStrength = updatePasswordStrength.bind(@)


    updatePasswordStrength= _.throttle( ->
        @passwordStrength = passwordHelper.getStrength @$inputPassword.val()

        if @passwordStrength.percentage is 0
            @passwordStrength.percentage = 1
        @$strengthBar.attr 'value', @passwordStrength.percentage
        @$strengthBar.attr 'class', 'pw-' + @passwordStrength.label
        @$inputPassword.removeClass('error')
    , 500)


    checkPasswordStrength: ->
        @updatePasswordStrength()


    # Get 1rst error only
    # err is an object such as:
    # { type: 'password', text:'step empty fields'}
    serializeData: () ->
        return Object.assign {}, @serializeInputData(), {
            error:      @error.message if @error
            id:         "#{@model.get 'name'}-figure"
            figureid:   require '../../assets/sprites/icon-lock.svg'
            passwordStrength: @passwordStrength
        }

    checkPasswordStrength: ->
        _.throttle(@updatePasswordStrength, 3000)()

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
            password: @$inputPassword.val()
            onboardedSteps: ['welcome', 'agreement', 'password']
        }

    serializeData: ->
        {
            passwordStrength: @passwordStrength
        }


    onSubmit: (event)->
        event?.preventDefault()
        if @passwordStrength.label is 'weak'
            @$inputPassword.addClass('error')
            return false
        else
            @model.submit @getDataFromDOM()
