###
Import Google step

This view do **not** rely on the machine state (except for the next stream push)
and uses basical Marionette logics to handle its internal events
###


module.exports = class RegisterImportGoogleView extends Mn.ItemView

    className: 'import-google'

    template: require 'views/templates/view_register_import_google'

    events:
        'click #lg-ok':             'selectedScopes'
        'click #step-pastecode-ok': 'pastedCode'
        'click #cancel':            'cancel'


    pastedCode: (event)->
        event.preventDefault()
        @popup?.close()
        @changeStep 'pickscope'

        @auth_code = @$("input:text[name=auth_code]").val()
        @$("input:text[name=auth_code]").val("")


    selectedScopes: (event)->
        event.preventDefault()

        scope =
            photos: false
            calendars: @$("input:checkbox[name=calendars]").prop("checked")
            contacts: @$("input:checkbox[name=contacts]").prop("checked")
            sync_gmail: false
            # Currently the Gmail sync is broken. So we remove it from the
            # scope until it's fixed.
            #sync_gmail: @$("input:checkbox[name=sync_gmail]").prop("checked")

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
        @$('#auth_code').focus() if step is 'pastecode'


    cancel: ->
        @model.setStep 'import'


    onRender: ->
        @changeStep 'pastecode'
        opts = [
            'toolbars=0'
            'width=700'
            'height=600'
            'left=200'
            'top=200'
            'scrollbars=1'
            'resizable=1'
        ].join(',')

        scopes = [
            'https://www.googleapis.com/auth/calendar.readonly'
            'https://picasaweb.google.com/data/'
            'https://www.googleapis.com/auth/contacts.readonly'
            'email'
            'https://mail.google.com/'
            'profile'
        ].join(' ')


        clientID = '260645850650-2oeufakc8ddbrn8p4o58emsl7u0r0c8s'
        clientID += '.apps.googleusercontent.com'

        oauthUrl = "https://accounts.google.com/o/oauth2/auth"
        oauthUrl += '?scope=' + encodeURIComponent(scopes)
        oauthUrl += '&response_type=code'
        oauthUrl += '&client_id=' + clientID
        oauthUrl += '&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob'
        @popup = window.open oauthUrl, 'Google OAuth',opts
        @changeStep 'pastecode'
