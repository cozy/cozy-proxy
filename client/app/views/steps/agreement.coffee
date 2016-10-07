{LayoutView} = require 'backbone.marionette'

module.exports = class AgreementView extends LayoutView
    template: require '../templates/view_steps_agreement'

    events:
        'click button': 'onSubmit'

    onSubmit: (event)->
        @model.submit()
