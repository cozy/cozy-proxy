{LayoutView} = require 'backbone.marionette'
Backbone = require 'backbone'

ProgressionView = require './steps/subviews/progression'

module.exports = class StepView extends LayoutView


    regions:
        progression: '.progression'


    initialize: (options) ->
        super(options)
        @progressionView = new ProgressionView \
            model: options.progression


    onRender: () ->
        @showChildView 'progression', @progressionView
