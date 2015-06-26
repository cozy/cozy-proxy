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
        @setStepBus = new Bacon.Bus()
        step = Bacon.update @steps[0],
            @setStepBus, (previous, newStep) ->
                if newStep? then newStep else previous
        @add 'step', step

        nextStep = Bacon.update null,
            step.changes(), (previous, newStep) =>
                return @steps[@steps.indexOf(newStep) + 1]
        @add 'nextStep', nextStep

        @setButtonEnableBus = new Bacon.Bus()
        nextButtonEnabled = Bacon.update true,
            step.changes(), (previous, step) => return step isnt @steps[0]
            @setButtonEnableBus, (previous, bool) -> return bool
        @add 'nextButtonEnabled', nextButtonEnabled


    setStep: (newStep) ->
        @setStepBus.push newStep
