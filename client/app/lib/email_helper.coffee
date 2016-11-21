# Return true if given email is a valid email, false either.
module.exports.validate = (email) ->
    # coffeelint: disable=max_line_length
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    # coffeelint: enable=max_line_length
    return email? and email.length > 0 and re.test(email)
