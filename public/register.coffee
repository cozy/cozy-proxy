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



    submitCredentials = ->
        $('.loading').spin 'small'
        client.post "register/",
            password: $('#password-input').val()
            email: $('#email-input').val()
        ,
            success: ->
                $('.loading').spin()
                $('.alert-success').fadeIn()
                setTimeout ->
                    $("body").fadeOut =>
                        setTimeout ->
                            window.location = "/"
                        , 500
                , 2000
            error: (err) ->
                $('.loading').spin()
                msg = JSON.parse(err.responseText).msg
                $('.alert-error').html msg
                $('.alert-error').fadeIn()

    text1 = 'Welcome to your Cozy!'
    text2 = "It's the first time you connect,"
    text3 = "Before going further I need you to give me:"
    $('h1').hide()
    $('input').hide()

    $($('h1')[0]).fadeIn 1500
    setTimeout =>
        $($('h1')[1]).fadeIn 1500
    , 500
    setTimeout =>
        $($('h1')[2]).fadeIn 1500
    , 1000
    setTimeout =>
        $('#email-input').fadeIn 1500
    , 1500
    setTimeout =>
        $('#password-input').fadeIn 1500
    , 2000

    $('#email-input').keyup (event) ->
        $('#password-input').focus() if event.which is 13

    $('#password-input').keyup (event) ->
        submitCredentials() if event.which is 13

    $('#email-input').focus()
