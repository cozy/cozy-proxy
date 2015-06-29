module.exports = class RegisterPresetView extends Mn.ItemView

    tagName: 'form'

    className: 'preset'

    template: require 'views/templates/view_register_preset'

    ui:
        email:    '#preset-email'
        name:     '#preset-name'
        password: '#preset-password'
        timezone: '#preset-timezone'


    onRender: ->
        inputs = _.map @ui, ($el, name) =>
            property = $el.asEventStream('keyup')
                       .map (event) -> event.target.value
                       .toProperty()
            @model.add name, property

        allFieldsFull = _.reduce inputs, (memo, property) ->
            memo.and property.map (value) -> value.length > 0
        , Bacon.constant false
        @model.setButtonEnableBus.plug allFieldsFull.changes()


    serializeData: ->
        res =
            timezones: require 'lib/timezones'
