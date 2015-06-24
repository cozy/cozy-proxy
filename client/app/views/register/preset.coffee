module.exports = class RegisterPresetView extends Backbone.Marionette.ItemView

    tagName: 'form'

    className: 'preset'

    template: require 'views/templates/view_register_preset'

    serializeData: ->
        res =
            timezones: require 'lib/timezones'
