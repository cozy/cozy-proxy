# Return given password srength as an object {percentage, label}
module.exports.getStrength = (password) ->
    if not password and password isnt ''
        throw new Error 'password parameter is missing'
    if not password.length
        # lowest level is 1 to display a little part of the strength bar
        # in the view
        return {percentage: 1, label: 'weak'}

    charsets = [
        # upper
        { regexp: /[A-Z]/g, size: 26 },
        # lower
        { regexp: /[a-z]/g, size: 26 },
        # digit
        { regexp: /[0-9]/g, size: 10 },
        # special
        { regexp: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/g, size: 30 }
    ]

    possibleChars = charsets.reduce (possibleChars, charset) ->
        if charset.regexp.test password
            possibleChars += charset.size
        return possibleChars
    , 0

    passwordStrength =
        (Math.log Math.pow(possibleChars, password.length)) / (Math.log 2)

    # levels
    _at33percent = 64
    _at66percent = 128
    _at100percent = 192

    if passwordStrength <= _at33percent # between 0 and 33%
        strengthPercentage = passwordStrength * 33 / _at33percent
        strengthLabel = 'weak'

    else if passwordStrength > _at33percent and passwordStrength <= _at66percent
        # between 33% and 66%
        strengthPercentage = passwordStrength * 66 / _at66percent
        strengthLabel = 'moderate'

    else # passwordStrength > 192
        #between 66% and 100%
        strengthPercentage = passwordStrength * 100 / _at100percent
        if strengthPercentage > 100
            strengthPercentage = 100
        strengthLabel = 'strong'

    return {percentage: strengthPercentage, label: strengthLabel}
