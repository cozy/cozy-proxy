StateModel = require 'lib/state_model'


module.exports = class Registration extends StateModel

    steps:
        preset:
           next : 'import'
        import:
            next: 'email'
        import_google:
            nocontrols: true
        email:
            next: 'setup'
        setup:
            next: 'welcome'
            nocontrols: true


    initialize: ->
        @buttonEnabled = new Bacon.Bus()
        @buttonBusy = new Bacon.Bus()
        @isRegistered = new Bacon.Bus()

        @setStepBus = new Bacon.Bus()
        isRegistered = @isRegistered.startWith(true).toProperty()
        step = Bacon.update null,
            [@setStepBus.filter isRegistered], (previous, step) ->
                if step? then step else previous
        @add 'step', step

        @add 'nextStep', next = step.map (step) => @steps[step]?.next or null
        @add 'hasControls', step.map (step) => not @steps[step]?.nocontrols

        @setStepBus.plug next.sampledBy @isRegistered
        @buttonEnabled.plug step.changes().map (step) =>
            return step isnt @steps[0]

        @buttonEnabled.startWith true
        @buttonBusy.startWith false


    setStep: (newStep) ->
        @setStepBus.push newStep
