StepView = require '../step'


module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click .next': 'onSubmit'
        'click [action=password-visibility]': 'onToggleVisibility'


    isVisible: false


    renderInput: =>
        data = @serializeInputData()

        # Show/hide password value
        @$('input[name=password]').attr 'type', data.inputType

        # Update Button title
        @$('[action=password-visibility]').attr 'alt', t(data.visibilityTxt)

        # Update Button Icon
        @$('.icon use').attr 'xlink:href', data.visibilityIcon


    # Get 1rst error only
    # err is an object such as:
    # { type: 'password', text:'step empty fields'}
    serializeData: () ->
        {
            error:      @error.message if @error
            stepName:   @model.get 'name'
            figureid:   require '../../assets/sprites/illustrate-password.svg'
        }


    serializeInputData: =>
        visibilityAction = if @isVisible then 'hide' else 'show'
        icon = require "../../assets/sprites/#{visibilityAction}-eye-icon.svg"
        type = if @isVisible then 'text' else 'password'
        {
            visibilityTxt: "step password #{visibilityAction}"
            visibilityIcon: icon
            inputType: type
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


    onSubmit: (event) ->
        event?.preventDefault()
        @model.submit @getDataFromDOM()
