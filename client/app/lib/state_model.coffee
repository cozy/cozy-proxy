module.exports = class StateModel

    properties: {}

    _cache: {}


    constructor: (options) ->

        @initialize()


    initialize: ->


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
