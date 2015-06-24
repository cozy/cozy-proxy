ControlsView = require 'views/register/controls'
FeedbackView = require 'views/register/feedback'


module.exports = class RegisterStepLayout extends Backbone.Marionette.LayoutView

    template: require 'views/templates/layout_register'

    regions:
        form:     'form'
        controls: '.controls'
        feedback: '.feedback'

    events:
        'click a': 'navigate'


    navigate: (event) ->
        event.preventDefault()
        app = require 'application'
        href = event.currentTarget.getAttribute 'href'
        app.router.navigate href, trigger: true


    initialize: ->
        @on 'before:show', @showFooter
        @listenTo @model, 'change:step', @swapStep


    swapStep: ->
        StepView = require "views/register/#{@model.get 'step'}"
        @showChildView 'form', new StepView model: @model


    showFooter: ->
        @showChildView 'controls', new ControlsView model: @model
        @showChildView 'feedback', new FeedbackView model: @model
