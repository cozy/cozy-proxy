jQuery = require 'jquery'

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
        if not data?.password
            errors.password = 'step empty fields'
        else if data.passwordStrength?.label is 'weak'
            errors.password = 'password too weak'

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
