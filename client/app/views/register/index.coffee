ControlsView = require 'views/register/controls'
FeedbackView = require 'views/register/feedback'


module.exports = class RegisterView extends Mn.LayoutView

    className: 'register'

    template: require 'views/templates/view_base'

    regions:
        'content':  '[role=region]'
        'controls': '.controls'
        'feedback': '.feedback'

    ui:
        footer: 'footer'


    initialize: ->
        @model.get('step').onValue @swapStep


    onRender: ->
        @showChildView 'controls', new ControlsView model: @model
        @showChildView 'feedback', new FeedbackView model: @model
        @model.get('hasControls').not().assign @ui.footer, 'attr', 'aria-hidden'


    swapStep: (step) =>
        return unless step
        StepView = require "views/register/#{step}"
        @showChildView 'content', new StepView model: @model
