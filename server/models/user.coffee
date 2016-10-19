cozydb = require 'cozydb'
Client = require('request-json').JsonClient
urlHelper = require 'cozy-url-sdk'

helpers      = require '../lib/helpers'
timezones    = require '../lib/timezones'
localization = require '../lib/localization_manager'
ArrayHelper = require '../lib/array_helper'

client = new Client urlHelper.dataSystem.url()
if process.env.NODE_ENV in ['production', 'test']
    client.setBasicAuth process.env.NAME, process.env.TOKEN

# hardcoded onboarding steps order and slug names
# TODO: find a way to define those step only server side or only client site.
ONBOARDING_STEPS = [
    'welcome',
    'agreement',
    'password',
    'infos',
    'accounts',
    'ending'
]

fixOnboardedSteps = (user) ->
    user.onboardedSteps = user.onboardedSteps or []
    # It seems that there is a bug, string Arrays are fetched like following:
    # [['text']] instead of ['text']
    # So until it's fixed, we prevent this issue by mapping the desired values
    # it the first array object is an array.
    if Array.isArray user.onboardedSteps[0]
        user.onboardedSteps = user.onboardedSteps[0]
    return user

module.exports = User = cozydb.getModel 'User',
    email: String
    password: String
    salt: String
    public_name: String
    timezone: String
    owner: Boolean
    allow_stats: Boolean
    isCGUaccepted: Boolean
    activated: Boolean
    encryptedOtpKey: String
    hotpCounter: Number
    authType: String
    encryptedRecoveryCodes: Array
    onboardedSteps: Array


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
        else
            user = fixOnboardedSteps users[0]
            callback null, user


User.getUsername = (callback) ->
    User.first (err, user) ->
        return callback err if err

        return callback() unless user and user.public_name

        callback null, user.public_name


User.validate = (data, errors = {}) ->
    if data.email and not helpers.checkEmail data.email
        errors.email = localization.t 'invalid email format'

    if data.timezone and not (data.timezone in timezones)
        errors.timezone = localization.t 'invalid timezone'

    return errors


User.checkInfos = (data) ->
    hasEmail = if data.email then helpers.checkEmail(data.email) else false
    hasUserName = data?.public_name
    hasTimezone = if data.timezone
        not (timezones.indexOf(data.timezone) is -1)
    else
        false
    return hasEmail and hasUserName and hasTimezone


User.validatePassword = (password, errors = {}) ->
    if not password? or password.length < 8
        errors.password = localization.t 'password too short'

    return errors

# Return the expected onboarding step for given userData
User.getCurrentOnboardingStep = (userData) ->
    return ONBOARDING_STEPS[0] unless userData and userData.onboardedSteps

    return ONBOARDING_STEPS.find (step) ->
        return userData.onboardedSteps.indexOf(step) is -1

# Returns true if user is complete and is ready to log into his Cozy.
# At this time this memthod check only if the user has completed all onboarding
# steps.
User.isRegistered = (userData) ->
    return ArrayHelper.areEquals userData?.onboardedSteps, ONBOARDING_STEPS
