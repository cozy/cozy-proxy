###
Main Login/ResetPassword view

Creates a view form that display the form to submit password (in sign in and
reset password mode). It inherits from `Mn.LayoutView` because it declares a
region to host form feedbacks (state-machine `alert` property).
###

FeedbackView = require 'views/auth/feedback'


module.exports = class AuthView extends Mn.LayoutView

    tagName: 'form'

    className: ->
        "#{@options.type} auth"

    attributes: ->
        data =
            method: 'POST'
            action: @options.backend

    template: require 'views/templates/view_auth'

    regions:
        'feedback': '.feedback'

    ui:
        passwd: 'input[type=password]'
        submit: '.controls button[type=submit]'


    ###
    Data exposed to template

    - username: username to display, gets from global vars
                (see server/views/index.jade#L14)
    - prefix: type is passed as prefix for locales translations
    ###
    serializeData: ->
        username: window.username
        prefix:   @options.type


    ###
    Initialize internals

    - streams outputted from DOM elements
    - properties extracted from streams
    ###
    initialize: ->
        # Create property for password input, delegated from the input element
        # events, mapped to its value
        password = @$el.asEventStream 'focus keyup blur', @ui.passwd
                        .map '.target.value'
                        .toProperty('')

        # Boolean property that confirms if the input is filled or not
        @passwordEntered = password.map (value) -> !!value

        # Submit stream, delegated from the submission event, and filtered by
        # the password input (submit can only be triggered if the password field
        # is not empty)
        submit = @$el.asEventStream 'click', @ui.submit
            .doAction '.preventDefault'
            .filter @passwordEntered

        # A complex property that contains the value of the form fields (here,
        # password only), and the action URL.
        # The property is sampled (changes occurs) by the form submit stream.
        formTpl =
            password: password
            action:   @options.backend
        form = Bacon.combineTemplate formTpl
            .sampledBy submit

        # Plug the form submission to the busy bus (set the button busy state
        # to true) and to the sign in bus to trigger the form submission in the
        # state-machine.
        @model.isBusy.plug form.map true
        @model.signin.plug form


    ###
    After rendering

    When template is rendered into the DOM, attach reactive actions to its
    elements.
    ###
    onRender: ->
        # Render the feedback child view
        @showChildView 'feedback', new FeedbackView
            forgot: @options.type is 'login'
            prefix: @options.type
            model:  @model

        # Select all password field content at focus
        @ui.passwd.asEventStream 'focus'
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

