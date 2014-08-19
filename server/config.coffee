path = require 'path'
americano = require 'americano'
cookieParser = require 'cookie-parser'
cookieSession = require 'cookie-session'
passport = require 'passport'
randomstring = require 'randomstring'
usetracker = require './middlewares/usetracker'
selectiveBodyParser = require './middlewares/selective_body_parser'

# /!\ CAREFUL /!\
# Middlewares order matters to authenticate websockets
# See ./server/lib/proxy.coffee
authSteps = [
    cookieParser randomstring.generate()
    cookieSession
        secret: randomstring.generate()
        maxage: 1000 * 60 * 60 * 24 * 7 # One week session
        secureProxy: process.env.NODE_ENV is 'production'
    passport.initialize()
    passport.session()
]

config =
    authSteps: authSteps
    supportedLanguages: ['en', 'fr']
    common:
        use: [
            americano.errorHandler
                dumpExceptions: true
                showStack: true
            americano.static path.join __dirname, '/../client/public'
            selectiveBodyParser
            usetracker
            authSteps[0]
            authSteps[1]
            authSteps[2]
            authSteps[3]
        ]
        set:
            views: path.join __dirname, 'views'

        engine:
            js: (path, locales, callback) ->
                callback null, require(path)(locales)

    development: [
        americano.logger 'dev'
    ]

    production: [
        americano.logger 'short'
    ]

    plugins: [
        'americano-cozy'
    ]

module.exports = config
