StateModel = require 'lib/state_model'


module.exports = class Registration extends StateModel

    steps:
        preset:
            next:      'import'
            nextLabel: 'sign up'
        import:
            next:      'email'
            nextLabel: 'skip'
        import_google:
            nocontrols: true
        email:
            next:      'setup'
            nextLabel: 'skip'
        setup:
            next:       'welcome'
            nocontrols: true
        welcome:
            nextLabel: 'welcome'


    initialize: ->
        @setStepBus      = new Bacon.Bus()
        @buttonEnabled   = new Bacon.Bus()
        @buttonBusy      = new Bacon.Bus()
        @nextButtonLabel = new Bacon.Bus()
        @isRegistered    = new Bacon.Bus()
        @errors          = new Bacon.Bus()
        @signup          = new Bacon.Bus()

        isRegistered = @isRegistered.startWith(true).toProperty()
        step = Bacon.update null,
            [@setStepBus.filter isRegistered], (previous, step) ->
                if step? then step else previous
        @add 'step', step

        @add 'nextStep', next = step.map (step) => @steps[step]?.next or null
        @add 'hasControls', step.map (step) => not @steps[step]?.nocontrols

        @setStepBus.plug next.sampledBy @isRegistered
        @buttonEnabled.plug step.map (step) ->
            return step isnt 'preset'

        @buttonEnabled.startWith true
        @buttonBusy.startWith false

        nextButtonLabel = Bacon.update 'next',
            [@nextButtonLabel], (previous, value) ->
                if value then value else previous
        @add 'nextButtonLabel', nextButtonLabel
        @nextButtonLabel.plug step.map (step) =>
            @steps[step]?.nextLabel

        @signup.onValue @signupSubmit


    setStep: (newStep) ->
        @setStepBus.push newStep


    signupSubmit: (formdata) =>
        req = Bacon.fromPromise $.post '/register', JSON.stringify formdata

        @isRegistered.plug req.map true
        @errors.plug req.mapError '.responseJSON.errors'
        @buttonBusy.plug req.mapEnd false
