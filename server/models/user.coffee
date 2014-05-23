americano = require 'americano-cozy'
Client = require('request-json').JsonClient

helpers = require '../lib/helpers'
timezones = require '../lib/timezones'

client = new Client process.env.DATASYSTEM_URL
if process.env.NODE_ENV in ['production', 'test']
    client.setBasicAuth process.env.NAME, process.env.TOKEN

module.exports = User = americano.getModel 'User',
    email: String
    password: String
    salt: String
    public_name: String
    timezone: String
    owner: Boolean
    activated: Boolean

User.createNew = (data, callback) ->
    data.docType = "User"
    client.post "user/", data, (err, res, body) ->
        if err? then callback err
        else if res.statusCode isnt 201
            err = "#{res.statusCode} -- #{body}"
            callback err
        else
            callback()

User::merge = (data, callback) ->
    client.put "user/merge/#{@id}/", data, (err, res, body) =>
        if err? then callback err
        else if res.statusCode is 404
            callback new Error "Model does not exist"
        else if res.statusCode isnt 200
            err = "#{res.statusCode} -- #{body}"
            callback err
        else
            callback()

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