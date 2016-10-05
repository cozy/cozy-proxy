{LayoutView} = require 'backbone.marionette'

module.exports = class ConfirmationView extends LayoutView
    template: require '../templates/view_steps_confirmation'

    events:
        'click button': 'onSubmit'

    onSubmit: (event)->
        @model.submit()
