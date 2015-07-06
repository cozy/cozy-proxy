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


    serializeData: ->
        data =
            username: window.username
            prefix:   @options.type


    initialize: (options) ->
        @options.next   ?= '/'
        @options.forgot = @options.type is 'login'

        password = @$el.asEventStream 'focus keyup blur', @ui.passwd
                        .map (event) -> event.target.value
                        .toProperty('')
        @passwordEntered = password.map (value) -> !!value

        submit = @$el.asEventStream 'click', @ui.submit
            .doAction '.preventDefault'
            .filter @passwordEntered

        formTpl =
            password: password
            action:   @options.backend
        form = Bacon.combineTemplate formTpl
            .sampledBy submit

        @model.isBusy.plug form.map true
        @model.signin.plug form


    onRender: ->
        @passwordEntered.not()
            .assign @ui.submit, 'attr', 'aria-disabled'

        @ui.passwd.asEventStream 'focus'
            .assign @ui.passwd[0], 'select'

        @model.isBusy
            .assign @ui.submit, 'attr', 'aria-busy'

        @model.success
            .doAction =>
                window.location.pathname = @options.next
            .map =>
                $ '<i/>',
                    class: 'fa fa-check'
                    text:  t "#{@options.type} auth success"
            .assign @ui.submit, 'html'

        @showChildView 'feedback', new FeedbackView
            forgot: @options.forgot
            prefix: @options.type
            model:  @model

        setTimeout =>
            @ui.passwd.focus()
        , 100
