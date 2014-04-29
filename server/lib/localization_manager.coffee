Polyglot = require 'node-polyglot'
Instance = require '../models/instance'

class LocalizationManager

    polyglot: null

    # should be run when app starts
    initialize: (callback) ->
        @retrieveLocale (err, locale) =>
            if err? then callback err
            else
                @polyglot = @getPolyglotByLocale locale
                callback null, @polyglot

    retrieveLocale: (callback) ->
        Instance.getLocale (err, locale) ->
            if err? or not locale then locale = 'en' # default value
            callback err, locale

    getPolyglotByLocale: (locale) ->
        try
            phrases = require "../../client/locales/#{locale}"
        catch err
            phrases = require '../../client/locales/en'
        return new Polyglot locale: locale, phrases: phrases

    # execute polyglot.t, for server-side localization
    t: (key, params = {}) -> return @polyglot?.t key, params

    # for template localization
    getPolyglot: -> return @polyglot

module.exports = new LocalizationManager()