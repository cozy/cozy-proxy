Locale   = require 'locale'
Polyglot = require 'node-polyglot'

Instance = require '../models/instance'

{supportedLanguages} = require '../config'
supported            = new Locale.Locales supportedLanguages


class LocalizationManager
    # Polyglot instance in the given locale
    polyglot: null

    constructor: ->
        Instance.getLocale (err, locale) =>
            locale = 'en' if err
            @setLocale locale


    setLocale: (locale) ->
        # Early return if locale is already the loaded one
        return if @polyglot?.locale is locale

        # Trying to find and use the best locale available in config
        locales = new Locale.Locales locale
        @setPolyglot locales.best supported


    setPolyglot: (locale) ->
        @requiredLocale = locale
        try
            phrases = require "../locales/#{locale}"

        catch err
            locale    = 'en'
            phrases = require '../locales/en'

        @polyglot = new Polyglot locale: locale, phrases: phrases
        return @polyglot


    getPolyglot: ->
        @setPolyglot @requiredLocale unless @polyglot
        return @polyglot


    # Expose Polyglot interns (i.e. for templating)
    # Those functions ensure polyglot is properly loaded before returning
    # content.
    getLocale: =>
        return @getPolyglot()?.locale()

    t: (key, params = {}) =>
        return @getPolyglot()?.t key, params


module.exports = new LocalizationManager()
