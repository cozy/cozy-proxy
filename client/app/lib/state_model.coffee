###
State-Machines top-level class

When building a state-machine (a viewModel object propulsed by Bacon), this
top-level class is used to provides common methods an properties.
###

Bacon = require 'baconjs'


module.exports = class StateModel

    # Properties stores to state-machines Bacon properties
    properties: {}

    # The internal _cache object stores the properties values. Not really the
    # good way to do it, but useful for the toJSON method called in
    # Backbone.View.render method.
    #
    # TODO: find a new way to get properties values instead of caching them
    # (which is totally contradictory with the FRP philosophy).
    _cache: {}


    ###
    Initialize

    If a hash of key:values is passed at initialization, they're added to the
    state-machine properties as a Bacon.constant property.
    ###
    constructor: (options) ->
        @add key, Bacon.constant(value) for key, value of options
        @initialize()


    initialize: ->


    ###
    Get property

    Returns the property from the `properties` object
    ###
    get: (name) ->
        if @properties[name] then @properties[name]
        else Bacon.constant(undefined)


    ###
    Add property

    Add a property to the `properties` object. When a new property is added, a
    handler is binded to its changes to updates the internal `_cache` object
    with its new value.
    ###
    add: (name, property) ->
        unless @properties[name]
            @properties[name] = property
            property.onValue (value) =>
                @_cache[name] = value
        return property


    ###
    `toJSON` simplies returns the `_cache` object to get current properties
    values.
    ###
    toJSON: ->
        return @_cache
