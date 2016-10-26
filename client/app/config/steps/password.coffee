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
        passwordStrength = passwordHelper.getStrength data.password
        if not data?.password
            errors.password = 'step empty fields'
        else if passwordStrength?.label is 'weak'
            errors.password = 'step password too weak'

        if Object.keys(errors).length
            return errors
        else
            return null


    save: (data) ->
        return new Promise((resolve, reject) ->
            jQuery.post({
                url: '/register'
                data: JSON.stringify data
                success: resolve
                error: (req) -> reject req.responseJSON
            }))
            .then @handleSaveSuccess, @handleSaveError

}
