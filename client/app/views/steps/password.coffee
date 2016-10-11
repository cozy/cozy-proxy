StepView = require '../step'

module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click button': 'doSubmit'


    serializeData: ->
        {
            title: 'Votre mot de passe'
            buttonLabel: 'CONTINUER'
        }


    getDataFromDOM: ->
        return { password: @$('input[name=password]').val() }


    doSubmit: (event)->
        event?.preventDefault()
        @model.submit @getDataFromDOM()
