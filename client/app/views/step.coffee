{LayoutView} = require 'backbone.marionette'
Backbone = require 'backbone'

ProgressionView = require './steps/subviews/progression'


module.exports = class StepView extends LayoutView

    regions:
        progression: '.progression'


    initialize: (options={}) ->
        super options

        @userModel = options.userModel
        @errors = options.errors

        @progressionView = new ProgressionView \
            model: options.progression


    onRender: () ->
        @showChildView 'progression', @progressionView
