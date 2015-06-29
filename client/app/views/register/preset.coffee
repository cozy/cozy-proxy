module.exports = class RegisterPresetView extends Mn.ItemView

    tagName: 'form'

    className: 'preset'

    template: require 'views/templates/view_register_preset'

    ui:
        email:    '#preset-email'
        name:     '#preset-name'
        password: '#preset-password'
        timezone: '#preset-timezone'


    initialize: ->
        @model.isRegistered.push false


    onRender: ->
        inputs = _.map @ui, ($el, name) =>
            $el.asEventStream('keyup')
               .map '.target.value'
               .toProperty('')

        allFieldsFull = _.reduce inputs, (memo, property) ->
            memo.and property.map (value) -> value.length > 0
        , Bacon.constant true
        @model.buttonEnabled.plug allFieldsFull.changes()

        Bacon.combineAsArray inputs
             .filter (v) -> _.compact(v).length is v.length
             .sampledBy @model.nextClickStream
             .onValues @onSubmit


    serializeData: ->
        res =
            timezones: require 'lib/timezones'


    onSubmit: (email, name, password, timezone) =>
        @model.buttonBusy.push true
        data =
            email:       email
            public_name: name
            timezone:    timezone
            password:    password
        req = Bacon.fromPromise $.post '/register', JSON.stringify data

        @model.isRegistered.plug req.map(true)
        @model.buttonBusy.plug req.mapEnd(false)
