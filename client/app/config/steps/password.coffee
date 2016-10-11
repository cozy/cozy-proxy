module.exports = {
    name: 'password',
    route: 'password',
    view : 'steps/password'

    # If OK, return null
    # if not return an Array of errors
    validate: (data) ->
        return null

    submit: (data) ->
        $.post '/register', JSON.stringify data
}
