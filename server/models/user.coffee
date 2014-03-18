americano = require 'americano-cozy'

helpers = require '../lib/helpers'
timezones = require '../lib/timezones'

module.exports = User = americano.getModel 'User',
    email: String
    password: String
    salt: String
    public_name: String
    timezone: String
    owner: Boolean
    activated: Boolean

User.first = (callback) ->
    User.request 'all', (err, users) ->
        if err then callback new err
        else if not users or users.length is 0 then callback null, null
        else  callback null, users[0]

User.validate = (data) ->

    errors = []
    errors = errors.concat User.validatePassword data.password

    if not helpers.checkEmail data.email
        errors.push 'Invalid email format'

    if not (data.timezone in timezones)
        errors.push 'Invalid timezone'

    return errors

User.validatePassword = (password) ->

    # errors is an array to prepare for other password format rules
    errors = []
    if not password? or password.length < 5
        errors.push 'Password is too short'

    return errors