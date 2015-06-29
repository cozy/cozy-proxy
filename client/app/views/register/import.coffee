module.exports = class RegisterImportView extends Mn.ItemView

    className: 'import'

    template: require 'views/templates/view_register_import'

    events:
        "click button#import-google": "clickImportGoogle"
        "click button#lg-ok": "selectedScopes"
        "click button#step-pastecode-ok": "pastedCode"

    clickImportGoogle: (event)->
        event.preventDefault()
        opts = [
            'toolbars=0'
            'width=700'
            'height=600'
            'left=200'
            'top=200'
            'scrollbars=1'
            'resizable=1'
        ].join(',')
        oauthUrl = "https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F\
        %2Fwww.googleapis.com%2Fauth%2Fcalendar.readonly%20https%3A%2F%2Fpicasa\
        web.google.com%2Fdata%2F%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fco\
        ntacts.readonly%20email%20profile&response_type=code&client_id=26064585\
        0650-2oeufakc8ddbrn8p4o58emsl7u0r0c8s.apps.googleusercontent.com&redire\
        ct_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob"
        @popup = window.open oauthUrl, 'Google OAuth',opts
        # @changeStep 'pastecode'

    pastedCode: (event)->
        event.preventDefault()
        @popup?.close()

        @auth_code = @$("input:text[name=auth_code]").val()
        @$("input:text[name=auth_code]").val("")


    selectedScopes: (event)->
        event.preventDefault()

        scope =
            photos: @$("input:checkbox[name=photos]").prop("checked")
            calendars: @$("input:checkbox[name=calendars]").prop("checked")
            contacts: @$("input:checkbox[name=contacts]").prop("checked")
            sync_gmail: @$("input:checkbox[name=sync_gmail]").prop("checked")

        $.post "/apps/leave-google/lg", {auth_code: @auth_code, scope: scope}
