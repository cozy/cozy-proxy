_ = require 'lodash'

# Check if an object has empty field: `keys` is an array that contains the keys
# the object should have. We check that each `obj[key]` exists and is not empty
hasEmptyField = module.exports.hasEmptyField = (obj, keys) ->
    i = 0
    while (key = keys[i])?
        value = obj[key]

        # Caveats:
        # 1. _.isEmpty returns true if tested against a boolean
        # 2. _.isEmpty returns true if tested against a number
        # 3. the keyword `not` needs paranthesis otherwise it takes the whole
        #    expression
        # 4. use paranthesis otherwise all hell breaks loose...
        unless value? and ((not _.isEmpty value) or (_.isBoolean value) or
        (_.isNumber value))
            return true
        i++

    return false


# Check that a set of elements has a correct structure: all elements must have
# the keys specified
module.exports.hasIncorrectStructure = (set, keys) ->
    i = 0
    while (obj = set[i])?
        if hasEmptyField obj, keys
            return true
        i++

    return false

