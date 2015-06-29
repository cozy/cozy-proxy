module.exports = class Registration

    properties: {}

    _cache: {}


    constructor: ->
        @initialize()


    get: (name) ->
        return @properties[name] if @properties[name]


    add: (name, property) ->
        unless @properties[name]
            @properties[name] = property
            property.onValue (value) =>
                @_cache[name] = value
        return property


    toJSON: ->
        return @_cache



    steps: [
        'preset',
        'import',
        'email',
        'setup',
        'welcome'
    ]


    initialize: ->
        @buttonEnabled = new Bacon.Bus()
        @buttonBusy = new Bacon.Bus()
        @isRegistered = new Bacon.Bus()

        @setStepBus = new Bacon.Bus()
        step = Bacon.update @steps[0],
            [@setStepBus.filter @isRegistered.toProperty()], (previous, step) ->
                if step? then step else previous
        @add 'step', step

        nextStep = Bacon.update @steps[1],
            step.changes(), (previous, newStep) =>
                return @steps[@steps.indexOf(newStep) + 1]
        @add 'nextStep', nextStep

        @setStepBus.plug nextStep.sampledBy @isRegistered
        @buttonEnabled.plug step.changes().map (step) =>
            return step isnt @steps[0]

        @buttonEnabled.push true
        @buttonBusy.push false
        @isRegistered.push true


    setStep: (newStep) ->
        @setStepBus.push newStep
