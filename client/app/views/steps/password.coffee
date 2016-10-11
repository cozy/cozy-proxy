StepView = require '../step'

module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click button': 'doSubmit'


    serializeData: ->
        {
            title: t 'step password title'
            description: t 'step password description'
            fieldLabel: t 'preset password'
            buttonLabel: t 'step password submit'
        }


    getDataFromDOM: ->
        return { password: @$('input[name=password]').val() }


    doSubmit: (event)->
        event?.preventDefault()
        @model.submit @getDataFromDOM()
