ControlsView = require 'views/register/controls'
FeedbackView = require 'views/register/feedback'


module.exports = class RegisterView extends Mn.LayoutView

    className: 'step'

    template: require 'views/templates/view_register'

    regions:
        'content':  '[role=region]'
        'controls': '.controls'
        'feedback': '.feedback'


    onRender: ->
        @showChildView 'controls', new ControlsView model: @model
        @showChildView 'feedback', new FeedbackView model: @model

        @model.get('step').onValue @swapStep


    swapStep: (step) =>
        return unless step
        StepView = require "views/register/#{step}"
        @showChildView 'content', new StepView model: @model
