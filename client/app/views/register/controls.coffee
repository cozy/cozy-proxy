module.exports = class RegisterControlsView extends Mn.ItemView

    template: require 'views/templates/view_register_controls'

    ui:
        'next': 'a.btn'


    initialize: ->
        @isImport  = @model.get('step').map (step) -> /^import/.test step
        @isWelcome = @model.get('step').map (step) -> /^welcome/.test step

        clickStream = @$el.asEventStream 'click', @ui.next
                          .doAction '.preventDefault'
                          .map (e) -> e.target.href.split('=')[1]
                          .filter @model.buttonEnabled.toProperty()
        @model.nextClickStream = clickStream
        @model.setStepBus.plug clickStream.filter @isWelcome.not()

        clickStream.map @isWelcome
                   .onValue (bool) -> window.location.pathname = '/' if bool


    onRender: ->
        @bindNext()
        @bindIsImport()
        @bindWelcome()


    bindNext: ->
        @model.buttonEnabled.toProperty().not()
              .assign @ui.next, 'attr', 'aria-disabled'

        @model.buttonBusy.toProperty()
              .assign @ui.next, 'attr', 'aria-busy'

        @model.get 'nextStep'
            .map (step) => "register?step=#{step}"
            .assign @ui.next, 'attr', 'href'

        @isImport.or(@isWelcome).not().map (bool) -> t 'next' if bool
                                      .assign @ui.next, 'text'


    bindIsImport: ->
        @isImport.not().assign @ui.next, 'toggleClass', 'btn-primary'
        @isImport.assign @ui.next, 'toggleClass', 'btn-secondary'
        @isImport.map (bool) -> t 'skip' if bool
                 .assign @ui.next, 'text'


    bindWelcome: ->
        @isWelcome.map (bool) -> t 'welcome' if bool
                  .assign @ui.next, 'text'
