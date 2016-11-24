jQuery = require 'jquery'
passwordHelper = require '../../lib/password_helper'

module.exports = {
    name: 'password',
    route: 'register/password',
    view : 'steps/password'

    # Return validation object
    # @see Onboarding.validate
    validate: (data={}) ->
        validation =
            success: false,
            errors: []
        if not data or not data.password
            validation.errors['password'] = 'step password empty'
        else if data.password
            passwordStrength = passwordHelper.getStrength data.password
            if passwordStrength?.label is 'weak'
                validation.errors['password'] = 'step password too weak'

        validation.success = Object.keys(validation.errors).length is 0
        return validation

    save: (data) ->
        return fetch '/register/password',
            method: 'POST',
            credentials: 'include',
            body: JSON.stringify data
        .then @handleSaveSuccess, @handleServerError
}
