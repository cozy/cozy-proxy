StepView = require '../step'

module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click button': 'doSubmit'


    getDataFromDOM: ->
        return { password: @$('input[name=password]').val() }


    doSubmit: (event)->
        event?.preventDefault()
        @model.submit @getDataFromDOM()
