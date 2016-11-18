jQuery = require 'jquery'
passwordHelper = require '../../lib/password_helper'

module.exports = {
    name: 'password',
    route: 'register/password',
    view : 'steps/password'

    # If OK, return null
    # if not return an Array of errors
    # that will be triggered throw onboarding
    # to dispatch error into app
    validate: (data={}) ->
        errors = {}
        if not data or not data.password
            errors.password = 'step password empty'
        else if data.password
            passwordStrength = passwordHelper.getStrength data.password
            if passwordStrength?.label is 'weak'
                errors.password = 'step password too weak'

        if Object.keys(errors).length
            return errors
        else
            return null


    save: (data) ->
        return fetch '/register/password',
            method: 'POST',
            body: JSON.stringify data
        .then @handleSaveSuccess, @handleServerError
}
