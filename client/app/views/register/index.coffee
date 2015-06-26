ControlsView = require 'views/register/controls'
FeedbackView = require 'views/register/feedback'


module.exports = class RegisterView extends Mn.LayoutView

    className: 'step'

    template: require 'views/templates/view_register'

    regions:
        'content':  '[role=region]'
        'controls': '.controls'
        'feedback': '.feedback'

    ui:
        next: '.controls a.btn'


    onRender: ->
        @showChildView 'controls', new ControlsView model: @model
        @showChildView 'feedback', new FeedbackView model: @model


    onBeforeShow: ->
        @model.get('step').onValue @swapStep
        @model.setStepBus.plug @$el.asEventStream 'click', @ui.next, (event) ->
            event.preventDefault()
            event.target.href.split('=')[1]


    swapStep: (step) =>
        return unless step
        StepView = require "views/register/#{step}"
        @showChildView 'content', new StepView model: @model
