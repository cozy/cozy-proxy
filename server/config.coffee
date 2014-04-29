path = require 'path'
americano = require 'americano'
passport = require 'passport'
randomstring = require 'randomstring'
usetracker = require './middlewares/usetracker'
selectiveBodyParser = require './middlewares/selectiveBodyParser'

# /!\ CAREFUL /!\
# Middlewares order matters to authenticate websockets
# See ./server/lib/proxy.coffee
authSteps = [
    americano.cookieParser randomstring.generate()
    americano.cookieSession
        secret: randomstring.generate()
        cookie: maxAge: 30 * 86400 * 1000
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
            views: path.join __dirname, '/../client/views'

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
