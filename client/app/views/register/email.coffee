###
Email account setting view

A view that contains a setup form for a primary email adress.
###

FormView = require 'views/lib/form_view'


module.exports = class RegisterEmailView extends FormView

    className: 'email'

    template: require 'views/templates/view_register_email'


    ###
    Initialize internal streams
    ###
    initialize: ->
        # Extends the FormView `@ui` object with specific selectors.
        @ui.legend = '.advanced legend'
        @ui.adv    = '.advanced .content'
        @ui.ssl    = 'input[type=checkbox][aria-controls]'

        # Creates a stream from the `fieldset > legend` element that returns if
        # the fieldset content is visible or not
        @showAdv = @$el.asEventStream 'click', @ui.legend
            .scan false, (visible) -> not visible
        # Creates a stream that returns the SSL checkbox value when this one
        # changed
        @sslCheck = @$el.asEventStream 'change', @ui.ssl
            .map '.target'


    ###
    Assign reactive actions
    ###
    onRender: ->
        # Show fieldset content and hide legend element when click on this last
        # one
        @showAdv.not().assign @ui.adv, 'attr', 'aria-hidden'
        @showAdv.assign @ui.legend, 'attr', 'aria-hidden'

        # Pre-fill the email input with the value of the email property from the
        # state-machine
        @model.get('email')?.assign @ui.inputs.filter('#email-email'), 'val'

        @initSSLCheckboxes()
        @bindSMTPServer()

        @initForm()

        # Create a submission stream from the form one that is filitered to the
        # step (can be triggered when we are in the email or setup step), and
        # plug it to the setEmail stream
        submit = @form.merge @model.nextClickStream
            .filter => @model.get('step').map (cur) -> cur in ['email', 'setup']
        @model.setEmail.plug submit

        # Create a stream based on the required inputs that transform the next
        # control button from 'skip' to 'add email acount' when they're all
        # filled
        @model.nextLabel.plug @required.map (bool) ->
            if bool then 'add email' else 'skip'


    ###
    Initialize the SSL checkboxes

    When clicking on a checkbox that controls an ssl-port input, then change
    this input value to pre-fill a right value, depending of the service and the
    state of the SSL checkbox.
    ###
    initSSLCheckboxes: ->
        @ui.ssl.each (indexs, el) =>
            service = el.id.match(/email-([a-z]{4})-ssl/i)[1]
            control = @$("##{el.getAttribute 'aria-controls'}")

            @sslCheck
                .filter (target) -> target is el
                .map (target) ->
                    ssl = target.checked
                    switch service
                        when 'imap' then (if ssl then 993 else 143)
                        when 'smtp' then (if ssl then 465 else 25)
                .assign control, 'val'


    ###
    Initialize smtp server input logic

    When fill the imap-server input, if the smtp-server input is empty or was
    never edited, then is takes the same value as the imap-server input. If it
    contains a custom value, it doesn't change.
    ###
    bindSMTPServer: ->
        imapServer  = @ui.inputs.filter('#email-imap-server')
        smtpServer  = @ui.inputs.filter('#email-smtp-server')

        smtpServer.asEventStream 'keyup'
            .map (e) -> !!e.target.value.length
            .assign smtpServer, 'data', 'edited'

        imapServer.asEventStream 'keyup'
            .map '.target.value'
            .filter -> smtpServer.data('edited')
            .assign smtpServer, 'val'
