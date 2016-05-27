locale   = require 'locale'
Polyglot = require 'node-polyglot'

Instance = require '../models/instance'

{supportedLanguages} = require '../config'


# Get locale from instance model and execute the given callback with it
getInstanceLocale = (callback) ->
    Instance.getLocale (err, lang) ->
        unless lang
            console.warn 'Fallback to "en" locale'
            lang = 'en'

        callback new locale.Locales(lang).toString()


class LocalizationManager
    # Polyglot instance in the given locale
    polyglot: null

    # Assume the locale returned by the Instance model is supported, and create
    # a polyglot container without validation.
    constructor: ->
        getInstanceLocale (lang) =>
            @polyglot = new Polyglot locale: lang


    setLocale: (lang, force) =>
        # Early return if locale is already the loaded one
        return lang if @polyglot.locale() is lang and not force

        # Trying to find and use the best locale available in config: create a
        # `Locale` from the gioven lang and compare it to the best supported
        # available locales.
        lang = (new locale.Locales lang).best(supportedLanguages).toString()
        @polyglot.locale lang
        @polyglot.extend require "../locales/#{lang}"
        return lang


    _getPolyglot: ->
        getInstanceLocale (lang) =>
            @setLocale lang
        # Early return polyglot after forced locale update
        return @polyglot


    # Expose Polyglot interns (i.e. for templating)
    # Those functions ensure polyglot is properly loaded before returning
    # content.
    locale: (lang) =>
        if lang
            @setLocale lang
        else
            @_getPolyglot().locale()

    t: (key, params = {}) =>
        @_getPolyglot().t key, params


module.exports = new LocalizationManager()
