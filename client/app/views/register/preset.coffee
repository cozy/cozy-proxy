###
Presets view

This view display the form for the preset step
###

Bacon = require 'baconjs'

FormView = require '../lib/form_view'


module.exports = class RegisterPresetView extends FormView

    className: 'preset'

    attributes:
        method: 'post'
        action: '/register'

    template: require '../templates/view_register_preset'


    serializeData: ->
        timezones: require '../../lib/timezones'


    ###
    Initialize internal streams and properties
    ###
    initialize: ->
        # Creates a new property in the state machine that contains the entered
        # email value to be used in later screens.
        email = Bacon.$.asEventStream.call @$el, 'blur', '#preset-email'
            .map '.target.value'
            .toProperty ''
        @model.add 'email', email

        # Create errors properties that will be used in the initError() method
        @errors =
            email:    @model.errors.map '.email'
            password: @model.errors.map '.password'
            timezone: @model.errors.map '.timezone'


    ###
    Assign reactive actions
    ###
    onRender: ->
        @initForm()
        @initErrors()

        # Step valve
        @onStep = @model.get('step').sampledBy(@form).map (step) ->
            step is 'preset'
        .toProperty()


        # Set the next button enable state when all required fields are filled
        @model.nextEnabled.plug @required.changes()

        # Create a new stream from the submit one that is filtered onto the step
        # (e.g. the form will not be submitted if we're already not in the step)
        submit = @form.filter @onStep
        # We plug it to the signup stream and to the next button busy state (e.g
        # the busy state is enable when the form is submitted)
        @model.signup.plug submit
        @model.nextBusy.plug submit.map true
