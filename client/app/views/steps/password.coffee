StepView = require '../step'

module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click button': 'onSubmit'


    serializeData: ->
        {
            title: 'Votre mot de passe'
            buttonLabel: 'CONTINUER'
        }


    getDataFromDOM: ->
        return { password: @$('input[name=password]').val() }


    onSubmit: (event)->
        event?.preventDefault()
        @model.submit @getDataFromDOM()
