FormView = require 'views/lib/form_view'


module.exports = class RegisterPresetView extends FormView

    className: 'preset'

    attributes:
        method: 'post'
        action: '/register'

    template: require 'views/templates/view_register_preset'


    serializeData: ->
        res =
            timezones: require 'lib/timezones'


    initialize: ->
        @isPreset = @model.get('step').map (step) -> step is 'preset'

        email = @$el.asEventStream 'blur', '#preset-email'
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

        @model.nextEnabled.plug @required.changes()

        submit = @form.filter @isPreset
        @model.signup.plug submit
        @model.nextBusy.plug submit.map true
