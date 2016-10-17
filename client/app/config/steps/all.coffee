# List of onboarding steps.
# Every steps are in the same file now, but the idea is to
# At this time there is only proper
welcome = require './welcome'
agreement = require './agreement'
infos = require './infos'
password = require './password'
accounts = require './accounts'
confirmation = require './confirmation'

module.exports = [
    welcome,
    agreement,
    infos,
    password,
    accounts,
    confirmation
]
