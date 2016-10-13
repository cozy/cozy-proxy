timezones = require '../../lib/timezones'
EmailHelper = require '../../lib/email_helper'

isValidTimezone = (timezone) ->
    return timezone? and not(timezones.indexOf(timezone) is -1)

isValidEmail = (email) ->
    return email? and EmailHelper.check(email)

module.exports = {
    name: 'infos',
    route: 'infos',
    view : 'steps/infos',
    isActive: (user) ->
        return not (isValidTimezone(user.timezone) and isValidEmail(user.email))
}
