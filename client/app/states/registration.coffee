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
            @setStepBus, (previous, newStep) -> return newStep
        @add 'step', step

        nextStep = Bacon.update null,
            step.changes(), (previous, newStep) =>
                return @steps[@steps.indexOf(newStep) + 1]
        @add 'nextStep', nextStep


    setStep: (newStep) ->
        @setStepBus.push newStep
