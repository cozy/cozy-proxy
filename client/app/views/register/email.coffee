FormView = require 'views/lib/form_view'


module.exports = class RegisterEmailView extends FormView

    className: 'email'

    template: require 'views/templates/view_register_email'


    initialize: ->
        @ui.legend = '.advanced legend'
        @ui.adv    = '.advanced .content'
        @ui.ssl    = 'input[type=checkbox][aria-controls]'

        @isEmail = @model.get('step').map (step) -> step in ['email', 'setup']

        @showAdv = @$el.asEventStream 'click', @ui.legend
            .scan false, (visible) -> not visible
        @sslCheck = @$el.asEventStream 'change', @ui.ssl
            .map '.target'


    onRender: ->
        @showAdv.not().assign @ui.adv, 'attr', 'aria-hidden'
        @showAdv.assign @ui.legend, 'attr', 'aria-hidden'

        @model.get('email')?.assign @ui.inputs.filter('#email-email'), 'val'

        @initSSLCheckboxes()
        @bindSMTPServer()

        @initForm()

        submit = @form.merge @model.nextClickStream
            .filter @isEmail
            .log()

        @model.nextLabel.plug @required.map (bool) ->
            if bool then 'add email' else 'skip'


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


    bindSMTPServer: ->
        imapServer  = @ui.inputs.filter('#email-imap-server')
        smtpServer  = @ui.inputs.filter('#email-smtp-server')
        filterValue = (value) -> (index, oldValue) ->
            if smtpServer.data('edited') then oldValue else value

        smtpServer.asEventStream 'keyup'
            .map '.target.value'
            .map (value) -> !!value.length
            .assign smtpServer, 'data', 'edited'

        imapServer.asEventStream 'keyup'
            .map '.target.value'
            .map filterValue
            .assign smtpServer, 'val'


    # onSubmit: (values) ->
    #     data =
    #         email:    values[0]
    #         password: values[1]
    #         server:   values[2]
    #         port:     values[3]
    #         ssl:      values[4]
    #         username: values[5]
    #     req = Bacon.fromPromise $.post '/register/email', JSON.stringify data
