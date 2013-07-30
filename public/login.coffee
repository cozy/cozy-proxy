$ ->

    # Prepare spin
    $.fn.spin = (opts, color, content) ->
        presets =
            tiny:
                lines: 8
                length: 2
                width: 2
                radius: 3

            small:
                lines: 8
                length: 1
                width: 2
                radius: 5

            large:
                lines: 10
                length: 8
                width: 4
                radius: 8

        if Spinner
            @each ->
                $this = $ this
                $this.html "&nbsp;"
                spinner = $this.data "spinner"
                if spinner?
                    spinner.stop()
                    $this.data "spinner", null
                    $this.html content

                else if opts isnt false
                    if typeof opts is "string"
                        if opts of presets
                            opts = presets[opts]
                        else
                            opts = {}
                        opts.color = color if color
                    spinner = new Spinner(
                        $.extend(color: $this.css("color"), opts))
                    spinner.spin this
                    $this.data "spinner", spinner

        else
            console.log "Spinner class not available."
            null


    submitPassword = ->
        $('#submit-btn').spin 'small'
        client.post "/login", { password: $('#password-input').val() },
            success: ->
                $('.alert-error').fadeOut()
                $('#forgot-password').hide()

                msg = "Sign in succeeded"

                if $(window).width() > 640
                    $('.alert-success').fadeIn()
                    $('.alert-success').html msg
                    $('#submit-btn').spin null, null, "Sign in"
                else
                    $('#submit-btn').spin null, null, msg
                setTimeout ->
                    newpath = window.location.pathname.substring 6 #/login
                    window.location.pathname = newpath
                , 500
            error: (err) ->
                $('.alert-success').fadeOut()
                $('.alert-error').hide()
                msg = JSON.parse(err.responseText).msg
                $('.alert-error').html msg
                if $(window).width() > 640
                    $('.alert-error').fadeIn()
                    $('#submit-btn').spin null, null, "Sign in"
                else
                    $('#submit-btn').spin null, null, "Sign in failed"
                $('#forgot-password').fadeIn()

    $('#password-input').keyup (event) ->
        submitPassword() if event.which == 13

    $('#submit-btn').click (event) ->
        submitPassword()

    $('#password-input').focus()

    $('#forgot-password').click (event) ->
        client.post "/login/forgot", {},
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
