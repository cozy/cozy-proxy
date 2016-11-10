StepView = require '../step'
_ = require 'underscore'

module.exports = class AccountsView extends StepView
    template: require '../templates/view_steps_accounts'

    ui:
        next: '.controls .next'

    events:
        'click @ui.next': 'onSubmit'


    onRender: (args...) ->
        super args...
        @$errorContainer=@$('.errors')

        if @error
            @renderError(@error)
        else
            @$errorContainer.hide()


    onSubmit: (event)->
        event.preventDefault()
        @triggerMethod 'browse:myaccounts', @model


    serializeData: ->
        _.extend super,
            id: "#{@model.get 'name'}-figure"
            figureid: require '../../assets/sprites/icon-cogs.svg'


    renderError: (error) ->
        @$errorContainer.html(t(error))
        @$errorContainer.show()
