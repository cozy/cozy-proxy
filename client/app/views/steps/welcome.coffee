{LayoutView} = require 'backbone.marionette'


module.exports = class WelcomeView extends LayoutView
    template: require '../templates/view_steps_welcome'

    events:
        'click button': 'onSubmit'


    initialize: (params={}) ->
        @actionsCreator = params.actionsCreator
        super params


    onSubmit: (event) ->
        event?.preventDefault()
        @actionsCreator.doSubmit()
