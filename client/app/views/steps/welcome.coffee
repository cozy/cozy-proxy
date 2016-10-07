{LayoutView} = require 'backbone.marionette'

module.exports = class WelcomeView extends LayoutView
    template: require '../templates/view_steps_welcome'

    events:
        'click button': 'onSubmit'

    onSubmit: (event)->
        @model.submit()
