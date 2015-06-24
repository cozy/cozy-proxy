module.exports = class RegisterPresetView extends Backbone.Marionette.ItemView

    template: require 'views/templates/view_register_preset'

    serializeData: ->
        res =
            timezones: require 'lib/timezones'
