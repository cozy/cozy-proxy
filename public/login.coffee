$ ->
    submitPassword = ->
        client.post "login/", { password: $('#password-input').val() },
            success: ->
                $('.alert-success').show()
                $('.alert-success').html "Sign in succeeded"
                window.location = "/"
            error: (err) ->
                msg = JSON.parse(err.responseText).msg
                $('.alert-error').html msg
                $('.alert-error').fadeIn()

    $('#password-input').keyup (event) ->
        submitPassword() if event.which == 13

    $('#password-input').focus()
