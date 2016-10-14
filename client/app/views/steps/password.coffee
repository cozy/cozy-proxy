StepView = require '../step'
_ = require 'underscore'


module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click button': 'doSubmit'

    serializeData: ->
        # Get 1rst error
        if(error = _.values(@errors?.errors).shift())
            return { error }
        else
            return {}


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
