$ ->
    submitPassword = ->
        client.post "/password/reset/#{key}", { password: $('#password-input').val() },
            success: ->
                $('.alert-error').fadeOut()
                $('.alert-success').fadeIn()
                $('.alert-success').html "Password reset succeeded"
                setTimeout ->
                    window.location = "/login"
                , 1500
            error: (err) ->
                $('.alert-success').fadeOut()
                msg = JSON.parse(err.responseText).msg
                $('.alert-error').html msg
                $('.alert-error').fadeIn()

    $('#password-input').keyup (event) ->
        submitPassword() if event.which == 13

    $('#password-input').focus()
