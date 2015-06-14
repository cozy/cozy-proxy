$ ->

    inputFields = $ '.input-wrapper'
    emailField = $ inputFields[0]
    passwordField = $ inputFields[1]
    passwordCheckField = $ inputFields[2]
    publicNameField = $ inputFields[3]
    timezoneField = $ inputFields[4]
    localeField = $ '#locale-input'

    buttonField = $ '#btn-wrapper'

    passwordInput = $ '#password-input'
    passwordCheckInput = $ '#password-check-input'
    emailInput = $ '#email-input'
    publicNameInput = $ '#publicName-input'
    languageInput = $ '#language-input'
    timezoneInput = $ '#timezone-input'
    errorAlert = $ '.alert-error'
    successAlert = $ '.alert-success'
    button = $ '#submit-btn'
    expandButton = $ '#expand-btn'
    buttonSeparator = $ '#btn-separator'
    reinsurance = $ '#reinsurance'


    submitCredentials = ->
        errorAlert.fadeOut()
        button.spin true
        client.post "register/",
            password: passwordInput.val()
            email: emailInput.val()
            public_name: publicNameInput.val()
            timezone: timezoneInput.val() or 'GMT'
            locale: localeField.val()
        ,
            success: ->
                button.spin()
                button.html REGISTRATION_SUCCEEDED
                button.addClass 'btn-success'
                successAlert.fadeIn()
                setTimeout ->
                    window.location = "/"
                , 1000

            error: (err) ->
                button.spin()
                button.html REGISTER_BUTTON
                msg = JSON.parse(err.responseText).msg
                errorAlert.html msg
                errorAlert.fadeIn()

    # contextuel tooltip management
    handleTooltip = ->
        firstSelector = $ $('.input-wrapper.invalid')[0]
        helpSelector = $ '.input-wrapper:not(invalid) .help.selected'
        helpSelector.removeClass 'selected'
        firstSelector.find('.help').addClass 'selected'

    $('input').focus handleTooltip
    $('input').blur handleTooltip

    # validators
    validateEmail = ->
        email = emailInput.val()
        re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        if email? and email.length > 0 and re.test(email) and email isnt ""
            emailField.find('.invalid').hide()
            emailField.find('.valid').show()
            emailField.removeClass 'invalid'
        else
            emailField.find('.valid').hide()
            emailField.find('.invalid').show()
            emailField.addClass 'invalid'

        handleSubmitButtonState()

    validatePassword = ->
        password = passwordInput.val()
        if password.length >= 5
            passwordField.find('.invalid').hide()
            passwordField.find('.valid').show()
            passwordField.removeClass 'invalid'
        else
            passwordField.find('.valid').hide()
            passwordField.find('.invalid').show()
            passwordField.addClass 'invalid'

        handleSubmitButtonState()

    validateCheckPassword = ->
        password = passwordInput.val()
        passwordCheck = passwordCheckInput.val()

        if password is passwordCheck
            passwordCheckField.find('.invalid').hide()
            passwordCheckField.find('.valid').show()
            passwordCheckField.removeClass 'invalid'
        else
            passwordCheckField.find('.valid').hide()
            passwordCheckField.find('.invalid').show()
            passwordCheckField.addClass 'invalid'

        handleSubmitButtonState()

    handleSubmitButtonState = ->
        invalidFieldsNum = $('.input-wrapper.invalid').length

        # must not be empty neither
        mandatoryFields = [
            emailInput.val()
            passwordInput.val()
            passwordCheckInput.val()
        ]

        emptyMandatoryFields = $.map mandatoryFields, (value) ->
                                    return value unless value is ""

        if invalidFieldsNum > 0 \
        or mandatoryFields.length isnt emptyMandatoryFields.length
            button.attr 'disabled', 'disabled'
        else
            button.removeAttr 'disabled'

    # validation
    emailInput.keyup (event) ->
        if event.which is 13
            validateEmail()
    emailInput.blur validateEmail
    passwordInput.keyup (event) ->
        if event.which is 13
            validatePassword()
            validateCheckPassword() if passwordCheckInput.val() isnt ""
    passwordInput.blur ->
        validatePassword()
        validateCheckPassword() if passwordCheckInput.val() isnt ""

    passwordCheckInput.keyup (event) ->
        if event.which is 13
            validateCheckPassword()
    passwordCheckInput.blur validateCheckPassword

    # chain the display of form fields
    emailInput.keydown (event) ->
        passwordInput.focus() if event.which is 13

    passwordInput.keydown (event) ->
        passwordCheckInput.focus() if event.which is 13
        passwordCheckField.fadeIn()

    passwordCheckInput.keydown (event) ->
        $('.btn-container.single').removeClass 'single'

    # bind the submit button
    button.click submitCredentials

    emailInput.focus()
