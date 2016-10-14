_ = require 'underscore'

StepView = require '../step'

module.exports = class WelcomeView extends StepView
    template: require '../templates/view_steps_welcome'

    events:
        'click button': 'onSubmit'

    onSubmit: (event)->
        @model.submit()


    serializeData: ->
        _.extend super,
            link:     'https://cozy.io'
            figureid: require '../../assets/sprites/illustration-welcome.svg'
