StepView = require '../step'

module.exports = class WelcomeView extends StepView
    template: require '../templates/view_steps_welcome'

    events:
        'click button': 'onSubmit'

    onSubmit: (event)->
        @model.submit()
