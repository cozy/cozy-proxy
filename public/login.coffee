$ ->
    submitPassword = ->
        client.post "login/", { password: $('#password-input').val() },
            success: ->
                $('.alert-error').fadeOut()
                $('#forgot-password').hide()
                $('.alert-success').fadeIn()
                $('.alert-success').html "Sign in succeeded"
                setTimeout ->
                    window.location = "/"
                , 500
            error: (err) ->
                $('.alert-success').fadeOut()
                $('.alert-error').hide()
                msg = JSON.parse(err.responseText).msg
                $('.alert-error').html msg
                $('.alert-error').fadeIn()
                $('#forgot-password').fadeIn()

    $('#password-input').keyup (event) ->
        submitPassword() if event.which == 13

    $('#password-input').focus()
    
    $('#forgot-password').click (event) ->
        client.post "login/forgot", {},
            success: ->
                $('.alert-error').fadeOut()
                $('.alert-success').fadeIn()
                $('.alert-success').html \
                    "An email have been sent to your mailbox, " + \
                    "follow its instructions to get a new password"
            error: (err) ->
                $('.alert-success').fadeOut()
                $('.alert-error').hide()
                msg = JSON.parse(err.responseText).msg
                $('.alert-error').html msg
                $('.alert-error').fadeIn()
