$ ->
    loader = $ '.loading'
    passwordInput = $ '#password-input'
    emailInput = $ '#email-input'
    errorAlert = $ '.alert-error'
    successAlert = $ '.alert-success'
    button = $ '#submit-btn'

    hideAll = ->
        wait 1000, ->
            progFadeOut [
                $($('h1')[0])
                $($('h1')[1])
                $($('h1')[2])
                emailInput
                passwordInput
                button
                successAlert
            ], =>
                $('img').fadeOut()
                wait 100, ->
                    window.location = "/"

    submitCredentials = ->
        errorAlert.fadeOut()
        loader.spin 'small'
        button.spin 'small'
        client.post "register/",
            password: passwordInput.val()
            email: emailInput.val()
        ,
            success: ->
                loader.spin()
                button.spin()
                button.html 'send informations'
                successAlert.fadeIn()
                hideAll()
            error: (err) ->
                loader.spin()
                button.spin()
                button.html 'send informations'
                msg = JSON.parse(err.responseText).msg
                errorAlert.html msg
                errorAlert.fadeIn()

    emailInput.keyup (event) ->
        passwordInput.focus() if event.which is 13

    passwordInput.keyup (event) ->
        submitCredentials() if event.which is 13

    button.click submitCredentials

    $('h1').hide()
    $('input').hide()
    button.hide()
    progFadeIn [
        $($('h1')[0])
        $($('h1')[1])
        $($('h1')[2])
        emailInput
        passwordInput
        button
    ], =>
        $('#email-input').focus()
