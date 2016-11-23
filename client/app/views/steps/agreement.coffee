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

        if @error
            @renderError(@error)
        else
            @$errorContainer.hide()


    serializeData: ->
        # the following figures object keys will be the
        # elementName in the related view
        _.extend super,
            figures:
                home: require '../../assets/sprites/icon-house.svg'
                privacy: require '../../assets/sprites/icon-padlock.svg'
                legal: require '../../assets/sprites/icon-hammer.svg'
                transparency: require '../../assets/sprites/icon-magnifier.svg'
                control: require '../../assets/sprites/icon-magic-finger.svg'
                community: require '../../assets/sprites/icon-smiley.svg'
            cguLink: 'https://cozy.io'


    onSubmit: (event)->
        event.preventDefault()
        allowStats = @ui.checkbox?[0].checked
        @model.submit {allowStats: allowStats}


    renderError: (error) ->
        @$errorContainer.html(t(error))
        @$errorContainer.show()
