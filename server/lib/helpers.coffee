bcrypt = require 'bcrypt'
Client = require('request-json').JsonClient
log = require('printit')
        date: false
        prefix: 'lib:helpers'

# Crypt given password with bcrypt algorithm.
module.exports.cryptPassword = (password) ->
    salt = bcrypt.genSaltSync 10
    hash = bcrypt.hashSync password, salt
    return { hash: hash, salt: salt }

# Send email giving user email address he can connect on to change his
# password. The validity of the address depends on the given key.
module.exports.sendResetEmail = (instance, user, key, callback) ->
    # must be required here to prevent cross dependency resolution
    localization = require './localization_manager'

    data =
        from: localization.t 'reset password email from',
            domain: instance.domain
        subject: localization.t 'reset password email subject'
        content: localization.t 'reset password email text',
            domain: instance.domain
            key: key

    client = new Client "http://localhost:9101/"
    if process.env.NODE_ENV is "production"
        client.setBasicAuth process.env.NAME, process.env.TOKEN
    client.post "mail/to-user/", data, (err, res, body) ->
        log.error err if err?
        callback err

# Return true if given email is a valid email, false either.
module.exports.checkEmail = (email)->
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    return email? and email.length > 0 and re.test(email)

module.exports.hideEmail = (email) ->
    email.split('@')[0]
        .replace '.', ' '
        .replace '-', ' '
