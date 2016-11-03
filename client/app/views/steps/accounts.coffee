StepView = require '../step'

module.exports = class AccountsView extends StepView
    template: require '../templates/view_steps_accounts'

    events:
        'click button': 'onSubmit'

    onSubmit: (event)->
        @model.submit()
