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
        return new Promise((resolve, reject) ->
            jQuery.post({
                url: '/register/password'
                data: JSON.stringify data
                success: resolve
                error: (req) -> reject req.responseJSON
            }))
            .then (response) =>
                # set response format to be compatible with expected fetch
                # response in Onboarding class
                response.ok = response.success
                @handleSaveSuccess response
            , (err) =>
                throw new Error 'step password server error' unless err
                @handleSaveError err
}
