# Return given password srength as an object {percentage, label}
module.exports.getStrength = (password) ->
    if not password and password isnt ''
        throw new Error 'password parameter is missing'
    if not password.length
        return {percentage: 0, label: 'weak'}

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
        (Math.log Math.pow(password.length, possibleChars)) / (Math.log 2)

    # levels
    _at33percent = 128
    _at66percent = 192
    _at100percent = 256

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
