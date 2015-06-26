module.exports = class RegisterControlsView extends Mn.ItemView

    template: require 'views/templates/view_register_controls'

    ui:
        'next': 'a.btn'


    onBeforeRender: ->
        clickStream = @$el.asEventStream('click', @ui.next)
                          .doAction('.preventDefault')
                          .map (e) -> e.target.href.split('=')[1]
        @model.setStepBus.plug clickStream


    onRender: ->
        @model.get('nextButtonEnabled')
            .not()
            .assign @ui.next, 'attr', 'aria-disabled'

        @model.get('nextStep')
            .map (step) => "register?step=#{step}"
            .assign @ui.next, 'attr', 'href'
