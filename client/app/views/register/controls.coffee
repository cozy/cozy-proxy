module.exports = class RegisterControlsView extends Backbone.Marionette.ItemView
    template: require 'views/templates/view_register_controls'

    modelEvents:
        'change:step': 'render'
