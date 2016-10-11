StepView = require '../step'

module.exports = class ConfirmationView extends StepView
    template: require '../templates/view_steps_confirmation'

    events:
        'click button': 'onSubmit'

    onSubmit: (event)->
        @model.submit()
