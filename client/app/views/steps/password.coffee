StepView = require '../step'

module.exports = class PasswordView extends StepView
    template: require '../templates/view_steps_password'

    events:
        'click button': 'onSubmit'


    serializeData: ->
        value = 'fakePasswordValue'
        {
            title: 'Votre mot de passe'
            buttonLabel: 'CONTINUER'
            value
        }


    onSubmit: (event)->
        event?.preventDefault()
        @model.submit()
