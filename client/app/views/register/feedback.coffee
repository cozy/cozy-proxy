module.exports = class RegisterFeedbackView extends Backbone.Marionette.ItemView
    template: require 'views/templates/view_register_feedback'


    initialize: ->
        @listenTo @model, 'change:step', @render

