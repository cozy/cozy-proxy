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
            email: 'toto@cozycloud.cc'
            public_name: 'toto'
            timezone: timezones[0]
            password: @$('input[name=password]').val()
            allow_stats: false
        }


    doSubmit: (event)->
        event?.preventDefault()
        @model.submit @getDataFromDOM()
