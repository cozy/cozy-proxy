module.exports = class RegisterControlsView extends Mn.ItemView

    template: require 'views/templates/view_register_controls'

    ui:
        'next': 'a.btn'


    initialize: ->
        @isWelcome = @model.get('step').map (step) -> 'welcome' is step

        clickStream = @$el.asEventStream 'click', @ui.next
                          .doAction '.preventDefault'
                          .map (e) -> e.target.href.split('=')[1]
                          .filter @model.get('nextControl').map '.enabled'
        @model.nextClickStream = clickStream
        @model.setStepBus.plug clickStream.filter @isWelcome.not()

        clickStream.map @isWelcome
                   .onValue (bool) -> window.location.pathname = '/' if bool


    onRender: ->
        @model.get 'nextControl'
            .map('.enabled').not()
            .assign @ui.next, 'attr', 'aria-disabled'

        @model.get 'nextControl'
            .map '.busy'
            .assign @ui.next, 'attr', 'aria-busy'

        @model.get 'nextStep'
            .map (step) -> if step then "register?step=#{step}" else '/'
            .assign @ui.next, 'attr', 'href'

        @model.get 'nextControl'
            .map '.label'
            .map (text) -> return -> t text
            .assign @ui.next, 'text'

        isSkip = @model.get 'nextControl'
            .map '.label'
            .map (text) -> text is 'skip'
        isSkip.assign @ui.next, 'toggleClass', 'btn-secondary'
        isSkip.not().assign @ui.next, 'toggleClass', 'btn-primary'
