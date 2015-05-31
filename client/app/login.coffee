$ ->
    wait = require('helpers').wait
    button = $ '#submit-btn'
    passwordInput = $ '#password-input'
    errorAlert = $ '.alert-error'
    successAlert = $ '.alert-success'
    forgotPassword = $ '#forgot-password'

    $('#proxy-form').submit (e) ->
        e.preventDefault()
        false

    submitPassword = ->
        button.spin true
        client.post "/login", { password: passwordInput.val() },
            success: ->
                errorAlert.hide()

                button.html LOGIN_SUCCESS_MESSAGE
                button.addClass 'btn-success'

                wait 1000, ->
                    $('#content').fadeOut ->
                        wait 500, ->
                            newpath = window.location.pathname.substring 6
                            window.location.pathname = newpath

            error: (err) ->
                msg = JSON.parse(err.responseText).error
                successAlert.hide()
                errorAlert.hide()
                errorAlert.html msg
                errorAlert.show()
                passwordInput.select()

                button.html LOGIN_BUTTON_LABEL

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
    passwordInput.select()
