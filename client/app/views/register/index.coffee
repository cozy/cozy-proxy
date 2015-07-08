###
Register root view

A Mn.LayoutView to handle the registration process and manipulates its views
flow easily. It declares 3 regions:
- a main region in which the current step view takes place
- a control region to display flow controls elements
- a feedback region to display the progression
###

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
        # assign the `swapStep` handler to the `step` property.
        @model.get('step').onValue @swapStep


    ###
    After render template into the DOM
    ###
    onRender: ->
        # attach controls and feedback subviews
        @showChildView 'controls', new ControlsView model: @model
        @showChildView 'feedback', new FeedbackView model: @model
        # assign the controls.visible property to the controls and feedback
        # container aria-hidden state
        @model.get 'nextControl'
            .map('.visible').not()
            .assign @ui.footer, 'attr', 'aria-hidden'


    ###
    Swap step child view
    ###
    swapStep: (step) =>
        return unless step
        StepView = require "views/register/#{step}"
        @showChildView 'content', new StepView model: @model
