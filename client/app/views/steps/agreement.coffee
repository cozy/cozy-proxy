StepView = require '../step'

module.exports = class AgreementView extends StepView
    template: require '../templates/view_steps_agreement'

    events:
        'click button': 'onSubmit'

    onSubmit: (event)->
        @model.submit()
