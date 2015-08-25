###
Auth state-machine

Exposed streams and properties used by the Login and ResetPassword views.
###

StateModel = require 'lib/state_model'


module.exports = class Auth extends StateModel

    initialize: ->
        # Declares all buses used to organize streams
        @isBusy    = new Bacon.Bus()    # enable/disable button busy state
        @alert     = new Bacon.Bus()    # alerts updates after submissions
        @success   = new Bacon.Bus()    # receive success returns after submit
        @signin    = new Bacon.Bus()    # form submission bus
        @sendReset = new Bacon.Bus()    # reset link submission

        # Adding an `alert` property that can be used in view rendering
        @add 'alert', @alert.toProperty()

        # Register the submission methods to their buses
        @signin.onValue @signinSubmit
        @sendReset.onValue @sendResetSubmit

        ###
        Redirect handler

        When a success respond to a sign in form submission, then get the `next`
        property value and redirect the user to this URL.
        ###
        @success.map @get 'next'
            .onValue (next) ->
                setTimeout ->
                    window.location.pathname = next
                , 500


    ###
    Sign in submission

    Submit a form in an ajax request and handle its response in a Bacon stream.

    - `form`: an object containing the form values
    ###
    signinSubmit: (form) =>
        data = JSON.stringify password: form.password
        req = Bacon.fromPromise $.post form.action, data

        # Plug success response to `@success` stream and set `@alert` to false
        # to reset it.
        @success.plug req.map '.success'
        @alert.plug req.map false

        # Plug error response to `@alert` stream. We assume it's always because
        # password isn't correct.
        @alert.plug req.errors().mapError
            status:  'error'
            title:   'wrong password title'
            message: 'wrong password message'

        # Plug ajax request end to reset the button `busy` state
        @isBusy.plug req.mapEnd false


    ###
    Reset link submission

    Submit the request to get a password recover link.
    ###
    sendResetSubmit: =>
        reset = Bacon.fromPromise $.post '/login/forgot'

        # Plug the request response to the `@alert` bus to display a message to
        # user that confirm the email sending.
        @alert.plug reset.map
            status:  'success'
            title:   'recover sent title'
            message: 'recover sent message'
