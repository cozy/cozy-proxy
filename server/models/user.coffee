americano = require 'americano-cozy'
Client    = require('request-json').JsonClient

helpers      = require '../lib/helpers'
timezones    = require '../lib/timezones'
localization = require '../lib/localization_manager'


client = new Client "http://localhost:9101/"
if process.env.NODE_ENV in ['production', 'test']
    client.setBasicAuth process.env.NAME, process.env.TOKEN

module.exports = User = americano.getModel 'User',
    email: String
    password: String
    salt: String
    public_name: String
    timezone: String
    owner: Boolean
    allow_stats: Boolean
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
    client.put "user/merge/#{@id}/", data, (err, res, body) ->
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
        if err then callback err
        else if not users or users.length is 0 then callback null, null
        else  callback null, users[0]

User.validate = (data, errors = {}) ->
    if not helpers.checkEmail data.email
        errors.email = localization.t 'invalid email format'

    if not (data.timezone in timezones)
        errors.timezone = localization.t 'invalid timezone'

    return errors

User.validatePassword = (password, errors = {}) ->
    if not password? or password.length < 8
        errors.password = localization.t 'password too short'

    return errors
