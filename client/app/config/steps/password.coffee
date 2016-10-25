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
        unless data.password?
            return { type: 'password', text:'step empty fields'}
        else
            return null


    save: (data) ->
        return fetch '/register',
            method: 'POST',
            body: JSON.stringify data
        .then @handleSaveSuccess, @handleSaveError

}
