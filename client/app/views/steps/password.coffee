StepView = require '../step'
_ = require 'underscore'

module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click button': 'doSubmit'


    # Get 1rst error only
    # err is an object such as:
    # { type: 'password', text:'step empty fields'}
    serializeData: () ->
        {
            error:      @error.message if @error
            stepName:   @model.get 'name'
            figureid:   require '../../assets/sprites/illustrate-password.svg'
        }


    getDataFromDOM: ->
        return {
            password: @$('input[name=password]').val()
            onboardedSteps: ['welcome', 'agreement', 'password']
        }


    getDataFromDOM: ->
        return { password: @$('input[name=password]').val() }


    doSubmit: (event)->
        event?.preventDefault()

        @model.submit @getDataFromDOM()
