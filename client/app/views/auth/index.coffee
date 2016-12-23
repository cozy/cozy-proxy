###
Main Login/ResetPassword view

Creates a view form that display the form to submit password (in sign in and
reset password mode). It inherits from `Mn.LayoutView` because it declares a
region to host form feedbacks (state-machine `alert` property).
###

Bacon = require 'baconjs'
$     = require 'jquery'

{LayoutView} = require 'backbone.marionette'

asEventStream = Bacon.$.asEventStream
passwordHelper = require '../../lib/password_helper'

module.exports = class AuthView extends LayoutView

    className: ->
        "#{@options.type} auth"

    attributes: ->
        data =
            method: 'POST'
            action: @options.backend

    template: require '../templates/view_auth'

    ui:
        passwd: 'input[name=password]'
        strengthBar: 'progress'
        authCode: 'input[name=otp]'
        form: 'form'
        submit: '.controls button[type=submit]'
        togglePasswordVisibility: 'button[name=password-visibility]'
        errorContainer: '.errors'
        forgot: 'a.forgot'
        recover: '.recover'
        recoverLabel: '.recover .coz-busy-label'


    ###
    Data exposed to template

    - username: username to display, gets from global vars
                (see server/views/index.jade#L14)
    ###
    serializeData: ->
        username: window.ENV.public_name
        otp:      window.ENV.otp
        type:     @options.type # login or reset
        figureid: require '../../assets/sprites/icon-cozy.svg'


    ###
    Initialize internals

    - streams outputted from DOM elements
    - properties extracted from streams
    ###
    initialize: ->
        # Create property for password input, delegated from the input element
        # events, mapped to its value
        password = asEventStream.call @$el, 'input', @ui.passwd
            .map '.target.value'
            # skipDuplicates avoid multiple updates and
            # errors message resetting
            .skipDuplicates()
            .toProperty('')

        password.onValue (value) =>
            @renderErrors ''
            @updatePasswordStrength value
            @toggleSubmitEnabling not not value

        # Same as above, this one is for the authentication code (OTP)
        auth = asEventStream.call @$el, 'focus keyup blur', @ui.authCode
            .map '.target.value'
            .toProperty('')

        # Boolean property that confirms if the input is filled or not
        @passwordEntered = password.map (value) -> !!value

        # Submit stream, delegated from the submission event, and filtered by
        # the password input (submit can only be triggered if the password field
        # is not empty)
        # To work on IE, we need to bind both button click and form submit
        submit = asEventStream.call @$el, 'click', @ui.submit
            .doAction '.preventDefault'
            .filter @passwordEntered

        submit = asEventStream.call @$el, 'submit', @ui.form
            .doAction '.preventDefault'
            .filter @passwordEntered

        # A complex property that contains the value of the form fields (here,
        # password only), and the action URL.
        # The property is sampled (changes occurs) by the form submit stream.
        formTpl =
            password: password
            auth:     auth
            action:   @options.backend
        form = Bacon.combineTemplate formTpl
            .sampledBy submit

        # Plug the form submission to the busy bus (set the button busy state
        # to true) and to the sign in bus to trigger the form submission in the
        # state-machine.
        @model.isBusy.plug form.map true
        @model.signin.plug form

        @model.get('alert').onValue (error) =>
            @renderErrors error.message


    updatePasswordStrength: (password) ->
        return unless password
        strength = passwordHelper.getStrength password

        if strength.percentage is 0
            strength.percentage = 1

        @ui.strengthBar.attr 'value', strength.percentage
        @ui.strengthBar.attr 'class', 'pw-' + strength.label

    ###
    After rendering

    When template is rendered into the DOM, attach reactive actions to its
    elements.
    ###
    onRender: ->
        @toggleSubmitEnabling false

        # Select all password field content at focus
        asEventStream.call @ui.passwd, 'focus'
            .assign @ui.passwd[0], 'select'

        # This is a ugly workaround to the autofocus issue: the field is marked
        # as `[autofocus]` so it gets the focus when the page loads. But if the
        # field is already filled (i.e. by the browser password manager), the
        # focus is properly given *but* the focus event isn't triggered, so the
        # select handler declared above isn't executed and the field content is
        # not selected.
        # So we force the focus after a short time (to let the DOM breath), to
        # trigger the `onFocus` event subscribers.
        setTimeout =>
            @ui.passwd.focus()
        , 100

        # Focus again to avoid blinks and ensure that everything is
        # selected.
        # Without it Firefox doesn't select the field content in every
        # cases.
        setTimeout =>
            @ui.passwd.focus()
        , 300

        # Assign the button busy state to the state-machine busy state
        @model.isBusy
            .assign @ui.submit, 'attr', 'aria-busy'

        # When the form is successfully submitted, change the submit button
        # content to a check mark…
        @model.success
            .map =>
                $ '<i/>',
                    class: 'fa fa-check'
                    text:  t "#{@options.type} auth success"
            .assign @ui.submit, 'html'

        # …and change its class to reflect success
        @model.success
            .assign @ui.submit, 'toggleClass', 'btn-success'

        # Re select all password field on failure.
        @model.alert
            .assign @ui.passwd[0], 'select'

        @ui.togglePasswordVisibility.on 'click', (event) =>
            event.preventDefault()
            @togglePasswordVisibility()

        @ui.forgot.on 'click', (event) =>
            event.preventDefault()
            if not @forgotDisabled
                @triggerMethod 'password:request'


    renderErrors: (message) ->
        @$(@ui.errorContainer)
            .text if !!message then t message else ''


    emptyErrors: () ->
        @renderErrors ''


    toggleSubmitEnabling: (force) ->
        @$(@ui.submit)
            .attr 'disabled', not force
            .attr 'aria-disabled', not force


    togglePasswordVisibility: () ->
        @isPasswordMasked ?= \
            @ui.passwd.attr('type') is 'password'

        @isPasswordMasked = not @isPasswordMasked

        @ui.passwd
            .attr 'type', if @isPasswordMasked then 'password' else 'text'

        @ui.togglePasswordVisibility
            .attr 'aria-pressed', \
                if @isPasswordMasked then false else true
            .attr 'title', if @isPasswordMasked \
                then t('step password show') \
                else t('step password hide')


    disableForgot: () ->
        @toggleForgot false


    enableForgot: () ->
        @toggleForgot true


    toggleForgot: (force) ->
        @forgotDisabled = \
            if force is undefined \
                then not @forgotDisabled \
                else not force

        @ui.forgot.attr 'aria-disabled': @forgotDisabled,
        @ui.recover.attr 'aria-busy': @forgotDisabled

        if @forgotDisabled
            @ui.recoverLabel
                .text t 'login recover busy'
