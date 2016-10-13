StepView = require '../step'

module.exports = class PasswordView extends StepView
    template: require '../templates/view_steps_password'

    events:
        'click button': 'onSubmit'

    render: ->
        super()

    onSubmit: (event)->
        event.preventDefault()
        @model.submit()
