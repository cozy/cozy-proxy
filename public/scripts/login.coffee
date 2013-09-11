$ ->
    loader = $('.loading')
    button = $('#submit-btn')
    passwordInput = $('#password-input')
    errorAlert = $('.alert-error')
    successAlert = $('.alert-success')
    forgotPassword = $('#forgot-password')

    submitPassword = ->
        button.spin 'small'
        loader.spin 'small'
        client.post "/login", { password: passwordInput.val() },
            success: ->
                errorAlert.hide()
                forgotPassword.hide()

                msg = "Sign in succeeded, let's go to the Cozy Home..."

                successAlert.html msg
                successAlert.fadeIn()
                loader.spin()
                button.spin()
                button.html 'sign in'

                wait 1000, ->
                    $('#content').fadeOut ->
                        wait 500, ->
                            newpath = window.location.pathname.substring 6
                            window.location.pathname = newpath

            error: (err) ->
                msg = JSON.parse(err.responseText).msg
                successAlert.fadeOut()
                errorAlert.hide()
                errorAlert.html msg
                errorAlert.fadeIn()

                loader.spin()
                button.spin()
                button.html "sign in"
                forgotPassword.fadeIn()

    passwordInput.keyup (event) ->
        submitPassword() if event.which == 13

    button.click submitPassword

    forgotPassword.click (event) ->
        client.post "/login/forgot", {},
            success: ->
                errorAlert.fadeOut()
                successAlert.fadeIn()
                successAlert.html \
                    "An email has been sent to your mailbox, " + \
                    "follow its instructions to get a new password"
            error: (err) ->
                successAlert.fadeOut()
                errorAlert.hide()
                msg = JSON.parse(err.responseText).msg
                errorAlert.html msg
                errorAlert.fadeIn()

    passwordInput.focus()
