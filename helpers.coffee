randomstring = require("randomstring")
bcrypt = require('bcrypt')
redis = require("redis")


# Crypt given password with bcrypt algorithm.
exports.cryptPassword = (password) ->
    salt = bcrypt.genSaltSync(10)
    hash = bcrypt.hashSync(password, salt)
    { hash: hash, salt: salt }

# Generate a random key and store it in the redis store
exports.genResetKey = () ->
    key = randomstring.generate()
    key

# Send email giving user email address he can connect on to change his
# password. The validity of the address depends on the given key.
exports.sendResetEmail = (instance, user, key, callback) ->
    nodemailer = require "nodemailer"
    transport = nodemailer.createTransport("SMTP", {})
    transport.sendMail
        to : user.email
        from : "Your Cozy Instance <no-reply@#{instance.domain}>"
        subject : "[Cozy] Reset password procedure"
        text: """
You told to your cozy that you forgot your password. No worry about that, just
go to following url and you will be able to set a new one:

https://#{instance.domain}/password/reset/#{key}
"""
    , (error, response) ->
        transport.close()
        callback error, response

# Return true if given email is a valid email, false either.
exports.checkMail = (email)->
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    email? and email.length > 0 and re.test(email)

exports.hideEmail = (email) ->
    email.split('@')[0]
        .replace '.', ' '
        .replace '-', ' '
