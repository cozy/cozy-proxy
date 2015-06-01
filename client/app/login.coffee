$ ->
    button = $ '#submit-btn'
    passwordInput = $ '#password-input'
    errorAlert = $ '.alert-error'
    successAlert = $ '.alert-success'
    forgotPassword = $ '#forgot-password'

    # Remove default behavior from form.
    $('#proxy-form').submit (e) ->
        e.preventDefault()
        false

    # When password is submitted, it sends it to the server for logging in.
    # If it's a success, a success message is displayed on the button. Then
    # it redirects the user to the home by changing the document path to "/".
    # It it's a failure, it displays an error message below the login button.
    onPasswordSubmitted = ->
        button.spin true
        client.post "/login", { password: passwordInput.val() },
            success: ->
                errorAlert.hide()

                button.html LOGIN_SUCCESS_MESSAGE
                button.addClass 'btn-success'

                setTimeout ->
                    $('#content').fadeOut ->
                        setTimeout ->
                            newpath = window.location.pathname.substring 6
                            window.location.pathname = newpath
                        , 500
                , 1000

            error: (err) ->
                msg = JSON.parse(err.responseText).error
                successAlert.hide()
                errorAlert.hide()
                errorAlert.html msg
                errorAlert.show()
                passwordInput.select()

                button.html LOGIN_BUTTON_LABEL

    # When forgotten password is clicked, it sends a request that will
    # run the reset procedure (send an email with an hidden link to reset the
    # password).
    onForgotPasswordClicked = (event) ->
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

    # Submit password if upped key is enter (key code is 13).
    onPasswordKeyUp = (event) ->
        submitPassword() if event.which is 13

    # Bind listeners to events
    passwordInput.keyup onPasswordKeyUp
    button.click onPasswordSubmitted
    forgotPassword.click onForgotPasswordClicked

    # Put the focus on the password field.
    passwordInput.focus()
    passwordInput.select()
