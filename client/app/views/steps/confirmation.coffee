{LayoutView} = require 'backbone.marionette'


module.exports = class ConfirmationView extends LayoutView
    template: require '../templates/view_steps_confirmation'

    events:
        'click button': 'onSubmit'

    initialize: (params={}) ->
        @actionsCreator = params.actionsCreator
        super params


    onSubmit: (event) ->
        event?.preventDefault()
        @actionsCreator.doSubmit()
