{LayoutView} = require 'backbone.marionette'

module.exports = class PasswordView extends LayoutView
    template: require '../templates/view_steps_password'

    events:
        'click button': 'onSubmit'

    render: ->
        super()

    onSubmit: (event)->
        event.preventDefault()
        @model.submit()
