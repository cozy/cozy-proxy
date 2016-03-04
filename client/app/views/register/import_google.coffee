###
Import Google step

This view do **not** rely on the machine state (except for the next stream push)
and uses basical Marionette logics to handle its internal events
###

Bacon = require 'baconjs'
$     = require 'jquery'

{ItemView} = require 'backbone.marionette'


module.exports = class RegisterImportGoogleView extends ItemView

    className: 'import-google'

    template: require '../templates/view_register_import_google'

    events:
        'click #cancel':            'cancel'
        'click #lg-ok':             'selectedScopes'
        'click #step-pastecode-ok': 'pastedCode'
        'click .nav':               'navToStep'


    pastedCode: (event)->
        event.preventDefault()

        @popup?.close()

        @auth_code = @$("input:text[name=auth_code]").val()
        @$("input:text[name=auth_code]").val("")

        @changeStep 'pickscope'



    selectedScopes: (event)->
        event.preventDefault()

        scope =
            photos:     false
            calendars:  @$("input:checkbox[name=calendars]").prop("checked")
            contacts:   @$("input:checkbox[name=contacts]").prop("checked")
            sync_gmail: false

        data = auth_code: @auth_code, scope: scope
        $.post "/apps/import-from-google/lg", data

        # Creates an array that represents the current imports and stores it
        # in the machine state if not empty
        imports = []
        imports.push 'contacts' if scope.contacts
        imports.push 'calendars' if scope.calendars
        @model.add 'imports', Bacon.constant(imports) if imports.length

        # Go to the next step
        @model.setStep 'setup'


    changeStep: (step) ->
        @$('.step').hide()
        @$("#step-#{step}").show()
        if step is 'pastecode'
            setTimeout (=> @$('#auth_code').focus()), 30
            @_authPopup()


    cancel: ->
        @model.setStep 'import'


    navToStep: (event) ->
        event.preventDefault()
        @changeStep event.currentTarget.dataset.target


    onRender: ->
        @changeStep 'sign-in'


    _authPopup: ->
        opts = "
            toolbars=0,
            width=700,
            height=600,
            left=200,
            top=200,
            scrollbars=1,
            resizable=1
        "

        scopes = "
            https://www.googleapis.com/auth/calendar.readonly
            https://picasaweb.google.com/data/
            https://www.googleapis.com/auth/contacts.readonly
            email
            https://mail.google.com/
            profile
        "

        clientID = "
            260645850650-2oeufakc8ddbrn8p4o58emsl7u0r0c8s\
            .apps.googleusercontent.com
        "

        oauthUrl = "
            https://accounts.google.com/o/oauth2/auth\
            ?scope=#{encodeURIComponent(scopes)}\
            &response_type=code\
            &client_id=#{clientID}\
            &redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob
        "

        @popup = window.open oauthUrl, 'Google OAuth',opts
