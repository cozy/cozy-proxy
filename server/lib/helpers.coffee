bcrypt = require 'bcrypt'
Client = require('request-json').JsonClient
urlHelper = require 'cozy-url-sdk'
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

    # cleanup domain: remove https and port number if needed
    domain = instance.domain
    if domain.indexOf('https://') isnt -1
        domain = domain.substring(8, domain.length)
    domain = domain.split(':')[0]
    data =
        from: localization.t 'reset password email from',
            domain: domain
        subject: localization.t 'reset password email subject'
        content: localization.t 'reset password email text',
            domain: instance.domain
            key: key

    client = new Client urlHelper.dataSystem.url()
    if process.env.NODE_ENV is "production"
        client.setBasicAuth process.env.NAME, process.env.TOKEN
    client.post "mail/to-user/", data, (err, res, body) ->
        if not err? and body?.error?
            err = body.error
        log.error err if err?
        callback err

# Return true if given email is a valid email, false either.
module.exports.checkEmail = (email)->
    # coffeelint: disable=max_line_length
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    # coffeelint: enable=max_line_length
    return email? and email.length > 0 and re.test(email)

module.exports.hideEmail = (email) ->
    email.split('@')[0]
        .replace '.', ' '
        .replace '-', ' '
