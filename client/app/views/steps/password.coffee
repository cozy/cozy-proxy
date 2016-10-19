StepView = require '../step'
timezones = require '../../lib/timezones'


module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click button': 'doSubmit'


    getDataFromDOM: ->
        # TODO: get user info
        # from server
        return {
            password: @$('input[name=password]').val()
            onboardedSteps: ['welcome', 'agreement', 'password']
        }


    doSubmit: (event)->
        event?.preventDefault()
        @model.submit @getDataFromDOM()
