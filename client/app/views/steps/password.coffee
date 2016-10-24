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


    checkPasswordStrength: ->
        _.throttle(@updatePasswordStrength, 3000)()


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


    onSubmit: (event)->
        event?.preventDefault()
        if @passwordStrength.label is 'weak'
            return false
        else
            @model.submit @getDataFromDOM()
