module.exports = class RegisterPresetView extends Mn.ItemView

    tagName: 'form'

    className: 'preset'

    attributes:
        method: 'post'
        action: '/register'

    template: require 'views/templates/view_register_preset'

    ui:
        labels:   'label.with-input'
        inputs:   'label input'
        email:    '#preset-email'


    serializeData: ->
        res =
            timezones: require 'lib/timezones'


    initialize: ->
        @isPreset = @model.get('step').map (step) -> step is 'preset'

        @inputsStream = @$el.asEventStream 'keyup blur change', @ui.inputs
        @submitStream = @$el.asEventStream 'submit'
            .doAction '.preventDefault'
            .filter @model.get('nextControl').map '.enabled'

        email = @$el.asEventStream 'blur', @ui.email
            .map '.target.value'
            .toProperty ''
        @model.add 'email', email

        @errors =
            email:    @model.errors.map '.email'
            password: @model.errors.map '.password'
            timezone: @model.errors.map '.timezone'


    onRender: ->
        @initForm()
        @initErrors()


    initForm: ->
        inputs   = {}
        required = Bacon.constant true

        getValue = (el) ->
            if el.type is 'checkbox' then el.checked else el.value

        @ui.inputs.map (index, el)=>
            property = @inputsStream.map '.target'
                .filter (target) -> target is el
                .map getValue
                .toProperty getValue el
            inputs[el.name] = property
            required = required.and(property.map (val) -> !!val) if el.required

        @model.nextEnabled.plug required.changes()
        form = Bacon.combineTemplate inputs
            .sampledBy @model.nextClickStream.merge @submitStream
            .filter @isPreset
        @model.signup.plug form
        @model.nextBusy.plug form.map true


    initErrors: ->
        isTruthy  = (value) -> !!value
        createMsg = (msg) -> $('<p/>', {class: 'error', text: msg})

        @model.errors
            .filter @isPreset
            .subscribe =>
                @ui.labels.find('.error').remove()

        for name, property of @errors
            $el = @ui.labels.filter("[for=preset-#{name}]")
            property.map isTruthy
                .assign $el, 'attr', 'aria-invalid'
            property.filter(isTruthy).map createMsg
                .assign $el, 'append'
