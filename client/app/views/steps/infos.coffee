StepView = require '../step'

module.exports = class InfosView extends StepView
    template: require '../templates/view_steps_infos'

    events:
        'click button': 'onSubmit'

    onSubmit: (event)->
        @model.submit()
