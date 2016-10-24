_ = require 'underscore'

StepView = require '../step'

module.exports = class WelcomeView extends StepView
    template: require '../templates/view_steps_welcome'

    ui:
        next: '.controls .next'

    events:
        'click @ui.next': 'onSubmit'

    onSubmit: (event) ->
        event.preventDefault()
        @model.submit()


    serializeData: ->
        _.extend super,
            link:     'https://cozy.io'
            id: "#{@model.get 'name'}-figure"
            figureid: require '../../assets/sprites/illustration-welcome.svg'
