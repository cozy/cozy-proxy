User = require '../models/user'

# We need to know the 2FA type used (none, HOTP or TOTP) in order to
# handle authentication correctly and to display or not the 2FA code field
# on the login page
module.exports.getAuthType = (next) ->
    User.first (err, user) ->
        if user
            if err
                next err
            else if user.authType
                next null, user.authType
            else # Standard authentication
                next null, null
        else
            next null, null