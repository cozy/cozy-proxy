module.exports = class RegisterControlsView extends Mn.ItemView

    template: require 'views/templates/view_register_controls'

    ui:
        'next': 'a.btn'


    onBeforeRender: ->
        clickStream = @$el.asEventStream('click', @ui.next)
                          .doAction('.preventDefault')
                          .map (e) -> e.target.href.split('=')[1]
                          .filter @model.buttonEnabled.toProperty()
        @model.setStepBus.plug @model.nextClickStream = clickStream


    onRender: ->
        @model.buttonEnabled.toProperty().not()
              .assign @ui.next, 'attr', 'aria-disabled'

        @model.buttonBusy.toProperty()
              .assign @ui.next, 'attr', 'aria-busy'

        @model.get('nextStep')
            .map (step) => "register?step=#{step}"
            .assign @ui.next, 'attr', 'href'
