module.exports = class RegisterControlsView extends Mn.ItemView

    template: require 'views/templates/view_register_controls'

    ui:
        'next': 'a.btn'


    onBeforeRender: ->
        @model.setStepBus.plug @$el.asEventStream 'click', @ui.next, (event) ->
            event.preventDefault()
            el = event.target

            return if el.getAttribute('aria-disabled') is 'true'
            el.href.split('=')[1]


    onRender: ->
        @model.get('nextButtonEnabled')
            .not()
            .assign @ui.next, 'attr', 'aria-disabled'

        @model.get('nextStep')
            .map (step) => "#{@ui.next.attr('href').split('=')[0]}=#{step}"
            .assign @ui.next, 'attr', 'href'
