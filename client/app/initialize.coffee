application = require './application'


initLocale = ->
        locale = $('html').attr 'lang'
        try phrases = require "locales/#{locale}"
        catch e
            phrases = require 'locales/en'
        polyglot = new Polyglot phrases: phrases, locale: locale
        # Temporary use a global variable to store the `t` helpers, waiting for
        # Marionette allow to register gloable helpers.
        # see https://github.com/marionettejs/backbone.marionette/issues/2164
        window.t = polyglot.t.bind polyglot

$ ->
    initLocale()
    application.start()
