{LayoutView} = require 'backbone.marionette'


module.exports = class WelcomeView extends LayoutView
    template: require '../templates/view_steps_welcome'

    events:
        'click button': 'goToNext'


    initialize: (params={}) ->
        @actionsCreator = params.actionsCreator
        super params


    goToNext: (event) ->
        event?.preventDefault()
        @actionsCreator.doSubmit()
