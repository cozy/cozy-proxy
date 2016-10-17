jQuery = require 'jquery'

REQUIRED_KEYS = ['username', 'email', 'public_name', 'timezone', 'allow_stats']


module.exports = {
    name: 'password',
    route: 'register/password',
    view : 'steps/password'


    # If OK, return null
    # if not return an Array of errors
    # that will be triggered throw onboarding
    # to dispatch error into app
    validate: (data={}) ->
        if (error = REQUIRED_KEYS.find (key) -> not data[key]?)
            return { type: 'user', text:'step empty fields', error}
        else unless data.password?
            return { type: 'password', text:'step empty fields'}
        else
            return null


    save: (data) ->
        return new Promise((resolve, reject) ->
            jQuery.post({
                url: '/register'
                data: JSON.stringify data
                success: resolve
                error: (req) => reject req.responseJSON
            })).then @handleSaveSuccess, @handleSaveError

}
