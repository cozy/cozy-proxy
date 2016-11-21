timezones = require '../../lib/timezones'
emailHelper = require '../../lib/email_helper'


# local function to validate email
isValidEmail = (email) ->
    return emailHelper.validate email


# Local function to validate timezone
isValidTimezone = (timezone) ->
    return timezone in timezones


module.exports = {
    name: 'infos',
    route: 'register/infos',
    view : 'steps/infos',
    isActive: (user) ->
        return not user.hasValidInfos

    # @see Onboarding.validate
    validate: (data) ->
        validation = success: false, errors: []

        ['public_name', 'email', 'timezone'].forEach (field) ->
            if not(typeof data[field] is 'undefined') \
                    and data[field].trim().length is 0
                validation.errors[field] = "missing #{field}"

        if data.email and not isValidEmail(data.email)
            validation.errors['email'] = 'invalid email format'

        if data.timezone and not isValidTimezone(data.timezone)
            validation.errors['timezone'] = 'invalid timezone'

        validation.success = Object.keys(validation.errors).length is 0

        return validation


    save: (data) ->
        data.onboardedSteps = [
            'welcome',
            'agreement',
            'password',
            'infos'
        ]
        return fetch '/register',
            method: 'PUT',
            # Authentify
            credentials: 'include',
            body: JSON.stringify data
        .then @handleSaveSuccess, @handleServerError
}
