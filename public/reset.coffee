$ ->
    button = $ '#submit-btn'
    passwordInput = $ '#password-input'
    errorAlert = $ '.alert-error'
    successAlert = $ '.alert-success'

    submitPassword = ->
        button.spin 'small'
        client.post "/password/reset/#{key}", { password: passwordInput.val() },
            success: ->
                button.spin()
                button.html 'change password'
                errorAlert.fadeOut()
                successAlert.fadeIn()
                successAlert.html "Password reset succeeded"
                wait 1000, ->
                    $("#content").fadeOut ->
                        window.location = "/login"
            error: (err) ->
                button.spin()
                button.html 'change password'
                successAlert.fadeOut()
                msg = JSON.parse(err.responseText).msg
                errorAlert.html msg
                errorAlert.fadeIn()

    passwordInput.keyup (event) ->
        submitPassword() if event.which is 13

    passwordInput.focus()
