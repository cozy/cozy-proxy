###
Register controls

A view dedicated to register flow control between its screens.
###

Bacon      = require 'baconjs'
{ItemView} = require 'backbone.marionette'


module.exports = class RegisterControlsView extends ItemView

    template: require '../templates/view_register_controls'

    ui:
        'next': 'a.btn'


    ###
    Initialize the view streams
    ###
    initialize: ->
        # The clickStream is the stream trigerred by click on next button
        # control. It:
        # - stops the natural event
        # - gets its step/route/url from href
        # - ensure the button is enabled (if not, the event isn't propagated
        # into the stream)
        clickStream = Bacon.$.asEventStream.call @$el, 'click', @ui.next
            .doAction '.preventDefault'
            .map (e) -> e.target.href.split('=')[1] or '/'
            .filter => @model.get('nextControl').map '.enabled'

        # We store the stream into the state-machine to get it accessible to
        # other views and plug it in the stepStepBus stream (as long as it
        # returns a step to route to)
        @model.nextClickStream = clickStream
        @model.setStepBus.plug clickStream


    ###
    Assign reactive logics after rendering template
    ###
    onRender: ->
        # Assign the disable state to the next button
        @model.get 'nextControl'
            .map('.enabled').not()
            .assign @ui.next, 'attr', 'aria-disabled'

        # Assign the busy state to the next button
        @model.get 'nextControl'
            .map '.busy'
            .assign @ui.next, 'attr', 'aria-busy'

        # Assign the nextStep value to the next button URL
        @model.get 'nextStep'
            .map (step) -> if step then "register?step=#{step}" else '/'
            .assign @ui.next, 'attr', 'href'

        # Assign the label to the next button
        @model.get 'nextControl'
            .map '.label'
            .filter (text) -> text isnt undefined
            .map (text) -> return -> t text
            .assign @ui.next, 'text'

        # When the next button is a "skip" button (i.e. go the the next step w/o
        # doing anything in the current screen) then pass its class to
        # `btn-secondary`
        isSkip = @model.get 'nextControl'
            .map '.label'
            .map (text) -> text is 'skip'
        isSkip.assign @ui.next, 'toggleClass', 'btn-secondary'
        isSkip.not().assign @ui.next, 'toggleClass', 'btn-primary'
