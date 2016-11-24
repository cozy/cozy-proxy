StepView = require '../step'
_ = require 'underscore'

module.exports = class ConfirmationView extends StepView
    template: require '../templates/view_steps_confirmation'

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


    onSubmit: (event) ->
        event.preventDefault()
        @model
            .submit()
            .then null, (error) =>
                @renderError error.message


    serializeData: ->
        _.extend super,
            id: "#{@model.get 'name'}-figure"
            figureid: require '../../assets/sprites/icon-raised-hands.svg'


    renderError: (error) ->
        @$errorContainer.html(t(error))
        @$errorContainer.show()
