

application = require './application'

$ ->
    polyglot = new Polyglot phrases: {}, locale: 'en'
    window.t = polyglot.t.bind polyglot

    application.start()
