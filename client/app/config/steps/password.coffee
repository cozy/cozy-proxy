jQuery = require 'jquery'

module.exports = {
    name: 'password',
    route: 'register/password',
    view : 'steps/password'

    # If OK, return null
    # if not return an Array of errors
    validate: (data) ->
        return null


    save: (data) ->
        return new Promise((resolve, reject) ->
            jQuery.post({
                url: '/register'
                data: JSON.stringify data
                success: resolve
                error: (req) => reject req.responseJSON
            })).then @handleSaveSuccess, @handleSaveError
