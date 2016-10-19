# Return given password complexity as a percentage
module.exports.getComplexityPercentage = (password) ->
    if not password?.length
        return 0
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

    else if passwordStrength > _at33percent and passwordStrength <= _at66percent
        # between 33% and 66%
        strengthPercentage = passwordStrength * 66 / _at66percent

    else # passwordStrength > 192
        #between 66% and 100%
        strengthPercentage = passwordStrength * 100 / _at100percent
        if strengthPercentage > 100
            strengthPercentage = 100

    return strengthPercentage
