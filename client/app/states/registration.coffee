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
        @setButtonEnableBus = new Bacon.Bus()
        nextButtonEnabled = Bacon.update true,
            @setButtonEnableBus, (previous, bool) -> return bool
        @add 'nextButtonEnabled', nextButtonEnabled

        @setStepBus = new Bacon.Bus()
        step = Bacon.update @steps[0],
            [nextButtonEnabled, @setStepBus], (previous, enabled, step) ->
                if enabled and step? then step else previous
        @add 'step', step
        @setButtonEnableBus.plug step.changes().map (step) => return step isnt @steps[0]

        nextStep = Bacon.update null,
            step.changes(), (previous, newStep) =>
                return @steps[@steps.indexOf(newStep) + 1]
        @add 'nextStep', nextStep



    setStep: (newStep) ->
        @setStepBus.push newStep
