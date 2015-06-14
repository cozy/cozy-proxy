$ ->
    wait = require('helpers').wait
    button = $ '#submit-btn'
    passwordInput = $ '#password-input'
    errorAlert = $ '.alert-error'
    successAlert = $ '.alert-success'

    submitPassword = ->
        button.spin 'small'
        client.post "/password/reset/#{key}", { password: passwordInput.val() },
            success: ->
                button.spin()
                button.html RESET_BUTTON
                errorAlert.fadeOut()
                successAlert.fadeIn()
                successAlert.html RESET_SUCCESS_MESSAGE
                wait 1000, ->
                    $("#content").fadeOut ->
                        window.location = "/login"
            error: (err) ->
                button.spin()
                button.html RESET_BUTTON
                successAlert.fadeOut()
                msg = JSON.parse(err.responseText).error
                successAlert.html RESET_ERROR_MESSAGE
                errorAlert.fadeIn()

    passwordInput.keyup (event) ->
        if event.which is 13 then submitPassword()

    button.click submitPassword

    passwordInput.focus()
