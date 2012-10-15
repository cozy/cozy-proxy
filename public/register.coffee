$ ->
    submitCredentials = ->
        client.post "register/",
                password: $('#password-input').val()
                email: $('#email-input').val()
            ,
                success: ->
                    $('.alert-success').html "Registration succeeded"
                    $('.alert-success').fadeIn()
                    setTimeout ->
                        window.location = "/"
                    , 1500
                error: (err) ->
                    msg = JSON.parse(err.responseText).msg
                    $('.alert-error').html msg
                    $('.alert-error').fadeIn()


    $('#email-input').keyup (event) ->
        $('#password-input').focus() if event.which == 13
    $('#password-input').keyup (event) ->
        submitCredentials() if event.which == 13

    $('#email-input').focus()
