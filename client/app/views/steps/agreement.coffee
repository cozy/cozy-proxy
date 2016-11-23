StepView = require '../step'
_ = require 'underscore'

module.exports = class AgreementView extends StepView
    template: require '../templates/view_steps_agreement'

    ui:
        next: '.controls .next'
        checkbox: '.checkbox input'

    events:
        'click @ui.next': 'onSubmit'


    onRender: ->
        @$errorContainer=@$('.errors')
        @$statsPart = @$('.stats-agreement')

        if @error
            @renderError(@error)
        else
            @$errorContainer.hide()

        # Environment variable to hide stats checkbox part
        if ENV.HIDESTATS
            @$statsPart.hide()


    serializeData: ->
        # the following figures object keys will be the
        # elementName in the related view
        _.extend super,
            figures: [
                require '../../assets/sprites/icon-shield.svg'
                require '../../assets/sprites/icon-hand-files.svg'
                require '../../assets/sprites/icon-forbidden-sign.svg'
                require '../../assets/sprites/icon-magnifier-user.svg'
                require '../../assets/sprites/icon-safe.svg'
                require '../../assets/sprites/icon-user.svg'
            ]
            cguLink: 'https://cozy.io'


    onSubmit: (event)->
        event.preventDefault()
        if ENV.HIDESTATS
            allowStats = false
        else
            allowStats = @ui.checkbox?[0].checked
        @model.submit {allowStats: allowStats}


    renderError: (error) ->
        @$errorContainer.html(t(error))
        @$errorContainer.show()
