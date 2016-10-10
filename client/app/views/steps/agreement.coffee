{LayoutView} = require 'backbone.marionette'


module.exports = class AgreementView extends LayoutView
    template: require '../templates/view_steps_agreement'

    events:
        'click button': 'onSubmit'


    initialize: (params={}) ->
        @actionsCreator = params.actionsCreator
        super params


    onSubmit: (event) ->
        event?.preventDefault()
        @actionsCreator.doSubmit()
