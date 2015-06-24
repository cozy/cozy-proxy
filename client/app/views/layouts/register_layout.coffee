ControlsView = require 'views/register/controls'
FeedbackView = require 'views/register/feedback'


module.exports = class RegisterStepLayout extends Backbone.Marionette.LayoutView

    template: require 'views/templates/layout_register'

    regions:
        content:  '.step'
        controls: '.controls'
        feedback: '.feedback'

    events:
        'click a': 'navigate'

    modelEvents:
        'change:step': 'swapStep'


    onBeforeShow: ->
        @showChildView 'controls', new ControlsView model: @model
        @showChildView 'feedback', new FeedbackView model: @model


    navigate: (event) ->
        event.preventDefault()
        app = require 'application'
        href = event.currentTarget.getAttribute 'href'
        app.router.navigate href, trigger: true


    swapStep: ->
        StepView = require "views/register/#{@model.get 'step'}"
        @showChildView 'content', new StepView model: @model
