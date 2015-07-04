module.exports = class RegisterPresetView extends Mn.ItemView

    tagName: 'form'

    className: 'preset'

    attributes:
        method: 'post'
        action: '/register'

    template: require 'views/templates/view_register_preset'

    ui:
        email:    '#preset-email'
        name:     '#preset-name'
        password: '#preset-password'
        timezone: '#preset-timezone'
        inputs:   'label.with-input'


    initialize: ->
        @isPreset = @model.get('step').map (step) -> step is 'preset'
        @model.isRegistered.push false

        @submitStream = @$el.asEventStream 'submit'
                            .doAction '.preventDefault'
                            .filter @model.buttonEnabled.toProperty()

        @model.add 'email', (@$el.asEventStream('blur', @ui.email)
            .map '.target.value'
            .toProperty '')

        @errors =
            stream: new Bacon.Bus()
            inputs: {}
        @errors.inputs.email    = @errors.stream.map '.email'
        @errors.inputs.password = @errors.stream.map '.password'
        @errors.inputs.timezone = @errors.stream.map '.timezone'


    onRender: ->
        inputs = _.map @ui, ($el, name) ->
            $el.asEventStream('keyup blur')
                .map '.target.value'
                .toProperty('')

        allFieldsFull = _.reduce inputs, (memo, property) ->
            memo.and property.map (value) -> value.length > 0
        , Bacon.constant true
        @model.buttonEnabled.plug allFieldsFull.changes()

        Bacon.combineAsArray inputs
            .filter (v) -> _.compact(v).length is v.length
            .sampledBy @model.nextClickStream.merge @submitStream
            .filter @isPreset
            .onValues @onSubmit

        @bindErrors()


    bindErrors: ->
        isTruthy  = (value) -> !!value
        createMsg = (msg) -> $('<p/>', {class: 'error', text: msg})

        @errors.stream.onValue =>
            @ui.inputs.find('.error').remove()

        for name, property of @errors.inputs
            $el = @ui.inputs.filter("[for=preset-#{name}]")
            property.map isTruthy
                .assign $el, 'attr', 'aria-invalid'
            property.filter(isTruthy).map createMsg
                .assign $el, 'append'


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

        @model.isRegistered.plug req.map true
        @errors.stream.plug req.mapError '.responseJSON.errors'
        @model.buttonBusy.plug req.mapEnd false
