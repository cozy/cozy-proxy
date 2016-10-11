StepView = require '../step'
timezones = require '../../lib/timezones'


module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click button': 'onSubmit'


    getDataFromDOM: ->
        # TODO: get user info
        # from server
        return {
            password: @$('input[name=password]').val()
            onboardedSteps: ['welcome', 'agreement', 'password']
        }


    getDataFromDOM: ->
        return { password: @$('input[name=password]').val() }


    onSubmit: (event)->
        event?.preventDefault()

        @model.submit @getDataFromDOM()
