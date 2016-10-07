# List of onboarding steps.
# Every steps are in the same file now, but the idea is to
# At this time there is only proper
welcome = require './welcome'
agreement = require './agreement'
password = require './password'
confirmation = require './confirmation'

module.exports = [
    welcome,
    agreement,
    password,
    confirmation
]
