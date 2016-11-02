StepView = require '../step'
_ = require 'underscore'

module.exports = class AccountsView extends StepView
    template: require '../templates/view_steps_accounts'

    ui:
        next: '.controls .next'

    events:
        'click @ui.next': 'onSubmit'

    onSubmit: (event)->
        event.preventDefault()
        @model.submit()

    serializeData: ->
        _.extend super,
            id: "#{@model.get 'name'}-figure"
            figureid: require '../../assets/sprites/icon-cogs.svg'
