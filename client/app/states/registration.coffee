StateModel = require 'lib/state_model'


module.exports = class Registration extends StateModel

    steps:
        preset:
            next:      'import'
            nextLabel: 'sign up'
        import:
            next:      'email'
            nextLabel: 'skip'
        import_google:
            nocontrols: true
        email:
            next:      'setup'
            nextLabel: 'skip'
        setup:
            next:       'welcome'
            nocontrols: true
        welcome:
            nextLabel: 'welcome'


    initialize: ->
        @errors = new Bacon.Bus()
        @initStep()
        @initControls()
        @initSignup()
        @initSetEmail()


    setStep: (newStep) ->
        @setStepBus.push newStep


    initStep: ->
        @setStepBus = new Bacon.Bus()
        @stepValve  = new Bacon.Bus()

        step = @setStepBus
            .holdWhen @stepValve.startWith(false).toProperty()
            .toProperty null

        @add 'step', step
        @add 'nextStep', step.map (step) => @steps[step]?.next or null
        @add 'previousStep', step.diff null, (previous, last) -> previous


    initControls: ->
        @nextEnabled = new Bacon.Bus()
        @nextBusy    = new Bacon.Bus()
        @nextLabel   = new Bacon.Bus()

        nextControl = Bacon.combineTemplate
            enabled: @nextEnabled.startWith(true).toProperty()
            busy:    @nextBusy.startWith(false).toProperty()
            label:   @nextLabel.startWith('next').toProperty()
            visible: @get('step').map (step) => not @steps[step]?.nocontrols

        @nextLabel.plug @get('step').map (step) => @steps[step]?.nextLabel

        @add 'nextControl', nextControl


    initSignup: ->
        @signup = new Bacon.Bus()

        @stepValve.plug @get('step').map (step) -> step is 'preset'
        @nextEnabled.plug @get('step').map (step) -> step isnt 'preset'
        @signup.onValue @signupSubmit


    signupSubmit: (formdata) =>
        req = Bacon.fromPromise $.post '/register', JSON.stringify formdata

        @stepValve.plug req.map false
        @errors.plug req.errors().mapError '.responseJSON.errors'
        @nextBusy.plug req.mapEnd false


    initSetEmail: ->
        @setEmail = new Bacon.Bus()
        @setEmail.onValue @setEmailSubmit


    setEmailSubmit: (data) =>
        login = data['imap-login'] or data.email
        accountData =
            id:                null
            label:             data.email
            name:              data.email.split('@')[0]
            login:             login
            password:          data.password
            accountType:       "IMAP"
            draftMailbox:      ""
            favoriteMailboxes: null
            imapPort:          data['imap-port']
            imapSSL:           data['imap-ssl']
            imapServer:        data['imap-server']
            imapTLS:           false
            smtpLogin:         data['smtp-login'] or login
            smtpMethod:        "PLAIN"
            smtpPassword:      data['smtp-password'] or data.password
            smtpPort:          data['smtp-port']
            smtpSSL:           data['smtp-ssl']
            smtpServer:        data['smtp-server'] or data['imap-server']
            smtpTLS:           false
            mailboxes:         ""
            sentMailbox:       ""
            trashMailbox:      ""

        $.ajax
            type:        'POST'
            url:         '/apps/emails/account'
            data:        JSON.stringify accountData
            contentType: "application/json; charset=utf-8",
            dataType:    'json'
