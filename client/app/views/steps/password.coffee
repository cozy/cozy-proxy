StepView = require '../step'
_ = require 'underscore'


module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click button': 'doSubmit'


    # Get 1rst error only
    # err is an object such as:
    # {type: 'user', text: 'step empty fields', error: 'username' }
    serializeData: () ->
        if (err = @errors)? and 'object' is typeof err
            err = err.shift() if err.length

            text = err.errors?.password
            text ?= t err.text, {name: err.error}

            return { error: text }
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
