###
Registration state-machine

Exposed streams and properties to the Register* views.
###

Bacon = require 'baconjs'
$     = require 'jquery'

StateModel = require '../lib/state_model'


module.exports = class Registration extends StateModel

    ###
    Registration process consists of a progress across many screens, in a
    non-linear mode. So, to keep it consistent, we declare the flow between
    screens in this step var. Each step can declares:
    - next: the step that comes after
    - nextLabel: the label for the next button flow control
    - nocontrols: hide the flow controls
    ###
    steps: do ->
        hasGoogleImport = 'import-from-google' in window.ENV.apps

        preset:
            next:      if hasGoogleImport then 'import' else 'setup'
            nextLabel: 'sign up'
        import:
            next:      'setup'
            nextLabel: 'skip'
        import_google:
            nocontrols: true
        setup:
            next:       'welcome'
            nocontrols: true
        welcome:
            nextLabel: 'welcome'


    initialize: ->
        # Initialize the bus to stream errors
        @errors = new Bacon.Bus()

        # Initialize each parts of registration process
        @initStep()
        @initControls()
        @initSignup()
        @initSetEmail()


    ###
    Set step property

    A simple wrapper to push the new step value in the `step` property.
    ###
    setStep: (newStep) ->
        @setStepBus.push newStep


    ###
    Initialize step flow

    Declares the streams and properties that'll be used to control step flow.
    ###
    initStep: ->
        @setStepBus = new Bacon.Bus()    # receive step updates
        @stepValve  = new Bacon.Bus()    # a valve property that can temporary
                                         # interrupt the step flow

        # `step` property (added to the state-machine below) is streamed by the
        # `setStepBus` stream, which is controlled by the `stepValve`, and
        # filtered to ensure that the step exists (i.e step exists in the
        # `steps` var)
        step = @setStepBus
            .holdWhen @stepValve.startWith(false).toProperty()
            .filter (step) => step in Object.keys @steps
            .toProperty null

        @add 'step', step
        # `nextStep` property contains the next step to come
        @add 'nextStep', step.map (step) => @steps[step]?.next or null


    ###
    Initialize the controls flow
    ###
    initControls: ->
        # Creates streams to handle controls state changes
        @nextEnabled = new Bacon.Bus()    # enable/disable the next button
        @nextBusy    = new Bacon.Bus()    # set next button busy state
        @nextLabel   = new Bacon.Bus()    # set next button label

        # To simply get next button state, we combine all streams / properties
        # that represents it in a complex coombined property. It can be easily
        # mapped to get state (e.g. `nextControl.map '.visible'` returns a
        # boolean that describes if the control should be visible or not, using
        # the `nocontrol` key declared in the `steps` var).
        nextControl = Bacon.combineTemplate
            enabled: @nextEnabled.startWith(true).toProperty()
            busy:    @nextBusy.startWith(false).toProperty()
            label:   @nextLabel.startWith('next').toProperty()
            visible: @get('step').map (step) => not @steps[step]?.nocontrols

        # We update the next button label using the `nextLabel` key in the
        # `steps` var. We use a Bus to stream the value (rather than map is like
        # the visible property above) to let views decides to update the label
        # themselves.
        @nextLabel.plug @get('step').map (step) => @steps[step]?.nextLabel

        # In case the next called step isn't declared in the `steps` var, we
        # assume it's a URL and navigate to it.
        @setStepBus
            .filter (value) => !(value in Object.keys @steps)
            .onValue (path) ->
                # /!\ we can't set only the pathname here, because
                # Chrome encodes it, replacing # with %23 See #195
                loc = window.location
                window.location.href = "#{loc.protocol}//#{loc.host}#{path}"


        # Add the `nextControl` property to the state-machine
        @add 'nextControl', nextControl


    ###
    Initialize sign up form
    ###
    initSignup: ->
        # Declares a stream to receive the form submission
        @signup = new Bacon.Bus()

        # If the current step is `preset`, set the valve to block the step flow:
        # it will resume when the sign up form request returns a success.
        @stepValve.plug @get('step').map (step) -> step is 'preset'
        # Disable the next button when enter in the `preset` step, it will be
        # re-enabled when all required inputs are filled
        @nextEnabled.plug @get('step').map (step) -> step isnt 'preset'
        # Subscribe the `onSignupSubmit` handler to the sign up stream
        @signup.onValue @signupSubmit


    ###
    Treats signup submission

    - data: an object containing the form input entries as key/values pairs
    ###
    signupSubmit: (data) =>
        # Submit the form content to the register endpoint and creates a stream
        # with the ajax promise
        req = Bacon.fromPromise $.post '/register', JSON.stringify data
        # If the request is successful, we stores the username in the global
        # scope to prepare the login view.
        req.subscribe -> window.username = data['public_name']
        # Unblock the step flow valve when the response is successful
        @stepValve.plug req.map false
        # Map request errors in the `errors` stream
        @errors.plug req.errors().mapError '.responseJSON.errors'
        # Map the request end to the next button busy state
        @nextBusy.plug req.mapEnd false


    ###
    Initialize email account creation form

    Simply creates a bus to get the form submission and subscribe the submission
    handler to this stream.
    ###
    initSetEmail: ->
        @setEmail = new Bacon.Bus()
        @setEmail.onValue @setEmailSubmit


    ###
    Treats email account creation form

    - data: an object containing the form input entries as key/values pairs
    ###
    setEmailSubmit: (data) ->
        # Map form data to the _email_ app endpoint expected form
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

        # We directly call the _emails_ app account creation endpoint and submit
        # the accountData. We do not attach any handler to the response as we
        # don't want to treat responses nor errors in onboarding: user will fix
        # a wrong setup in the _emails_ app directly.
        $.ajax
            type:        'POST'
            url:         '/apps/emails/account'
            data:        JSON.stringify accountData
            contentType: "application/json; charset=utf-8",
            dataType:    'json'
