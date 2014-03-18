$ ->
    wait = require('helpers').wait
    loader = $ '.loading'
    button = $ '#submit-btn'
    passwordInput = $ '#password-input'
    errorAlert = $ '.alert-error'
    successAlert = $ '.alert-success'
    forgotPassword = $ '#forgot-password'
    submitPassword = ->
        button.spin 'small'
        loader.spin 'small'
        client.post "/login", { password: passwordInput.val() },
            success: ->
                errorAlert.hide()
                forgotPassword.hide()

                successAlert.html LOGIN_SUCCESS_MESSAGE
                successAlert.fadeIn()
                loader.spin()
                button.spin()
                button.html

                wait 1000, ->
                    $('#content').fadeOut ->
                        wait 500, ->
                            newpath = window.location.pathname.substring 6
                            window.location.pathname = newpath

            error: (err) ->
                msg = JSON.parse(err.responseText).error
                successAlert.fadeOut()
                errorAlert.hide()
                errorAlert.html msg
                errorAlert.fadeIn()

                loader.spin()
                button.spin()
                button.html LOGIN_BUTTON_LABEL
                forgotPassword.fadeIn()

    passwordInput.keyup (event) ->
        submitPassword() if event.which is 13

    button.click submitPassword

    forgotPassword.click (event) ->
        client.post "/login/forgot", {},
            success: ->
                errorAlert.fadeOut()
                successAlert.fadeIn()
                successAlert.html RESET_SUCCESS_MESSAGE
            error: (err) ->
                successAlert.fadeOut()
                errorAlert.hide()
                msg = JSON.parse(err.responseText).msg
                errorAlert.html msg
                errorAlert.fadeIn()

    passwordInput.focus()
