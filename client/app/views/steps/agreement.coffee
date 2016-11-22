StepView = require '../step'
_ = require 'underscore'

module.exports = class AgreementView extends StepView
    template: require '../templates/view_steps_agreement'

    events:
        'click button': 'onSubmit'


    serializeData: ->
        _.extend super,
            home_figure: require '../../assets/sprites/icon-house.svg'
            privacy_figure: require '../../assets/sprites/icon-padlock.svg'
            legal_figure: require '../../assets/sprites/icon-hammer.svg'
            transparency_figure:
                require '../../assets/sprites/icon-magnifier.svg'
            control_figure: require '../../assets/sprites/icon-magic-finger.svg'
            community_figure: require '../../assets/sprites/icon-smiley.svg'


    onSubmit: (event)->
        @model.submit()
