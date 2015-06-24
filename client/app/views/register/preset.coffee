module.exports = class RegisterPresetView extends Mn.ItemView

    tagName: 'form'

    className: 'preset'

    template: require 'views/templates/view_register_preset'

    serializeData: ->
        res =
            timezones: require 'lib/timezones'
