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
                    $('img').fadeOut()
                    progFadeOut [$($('h1')[0]), $($('h1')[1]), $($('h1')[2]), $('#email-input'), $('#password-input'), $(".alert-success")], =>
                        setTimeout ->
                            window.location = "/"
                        , 200
                , 1000
            error: (err) ->
                $('.loading').spin()
                msg = JSON.parse(err.responseText).msg
                $('.alert-error').html msg
                $('.alert-error').fadeIn()

    progFadeIn = (objs, callback) ->
        if objs.length is 1
            obj = objs.shift()
            obj.fadeIn 800, callback
        else if objs.length > 0
            obj = objs.shift()
            obj.fadeIn 800
            setTimeout =>
                progFadeIn objs, callback
            , 100

    progFadeOut = (objs, callback) ->
        if objs.length is 1
            obj = objs.pop()
            console.log callback
            obj.fadeOut 800, callback
        if objs.length > 0
            obj = objs.pop()
            obj.fadeOut 800
            setTimeout =>
                progFadeOut objs, callback
            , 100

    $('h1').hide()
    $('input').hide()
    progFadeIn [$($('h1')[0]), $($('h1')[1]), $($('h1')[2]), $('#email-input'), $('#password-input')], =>
        $('#email-input').focus()

    $('#email-input').keyup (event) ->
        $('#password-input').focus() if event.which is 13

    $('#password-input').keyup (event) ->
        submitCredentials() if event.which is 13
