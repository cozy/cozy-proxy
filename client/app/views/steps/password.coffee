StepView = require '../step'


module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click .next': 'onSubmit'
        'click [action=password-visibility]': 'onToggleVisibility'


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
        @$visibilityButton.attr 'alt', t(data.visibilityTxt)

        # Update Button Icon
        @$visibilityIcon.attr 'xlink:href', data.visibilityIcon


    # Get 1rst error only
    # err is an object such as:
    # { type: 'password', text:'step empty fields'}
    serializeData: () ->
        return Object.assign {}, @serializeInputData(), {
            error:      @error.message if @error
            id:         "#{@model.get 'name'}-figure"
            figureid:   require '../../assets/sprites/illustrate-password.svg'
        }


    serializeInputData: =>
        visibilityAction = if @isVisible then 'hide' else 'show'
        icon = require "../../assets/sprites/#{visibilityAction}-eye-icon.svg"
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
        @model.submit @getDataFromDOM()
