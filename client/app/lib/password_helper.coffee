# Return given password srength as an object {percentage, label}
module.exports.getStrength = (password) ->
    if not password and password isnt ''
        throw new Error 'password parameter is missing'
    if not password.length
        {percentage: 0, label: 'weak'}
    charsPoints = 0
    upperPoints = if ((password.match(/[A-Z]/g) || []).length) then 26 else 0
    lowerPoints = if ((password.match(/[a-z]/g) || []).length) then 26 else 0
    digitPoints = if ((password.match(/[0-9]/g) || []).length) then 10 else 0
    specialPoints =
        if ((password.match(/[^A-Za-z0-9]]/g) || []).length) then 10 else 0

    charsPoints += upperPoints + lowerPoints + digitPoints + specialPoints

    passwordStrength =
        (Math.log Math.pow(password.length, charsPoints)) / (Math.log 2)

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
