_ = require 'underscore'

StepView = require '../step'


FORMS_DIS_ELEMENTS = [
    'button'
    'command'
    'fieldset'
    'input'
    'keygen'
    'optgroup'
    'option'
    'select'
    'textarea'
]


module.exports = class WelcomeView extends StepView
    template: require '../templates/view_steps_welcome'

    ui:
        next: '.controls .next'

    events:
        'click @ui.next': 'onSubmit'


    onSubmit: (event) ->
        event.preventDefault()
        @model.submit() unless @isDisabled()
        @setDisabled()


    setDisabled: ($el = @ui.next) ->
        if $el[0].tagName.toLowerCase() in FORMS_DIS_ELEMENTS
            $el
                .prop 'disabled', true
                .attr 'aria-busy', true
        else
            $el.attr
                'aria-disabled': true
                'aria-busy':     true


    isDisabled: ($el = @ui.next) ->
        if $el[0].tagName.toLowerCase() in FORMS_DIS_ELEMENTS
            $el.prop('disabled')
        else
            $el.attr('aria-disabled') is 'true'


    serializeData: ->
        _.extend super,
            link:     'https://cozy.io'
            id: "#{@model.get 'name'}-figure"
            figureid: require '../../assets/sprites/illustration-welcome.svg'
