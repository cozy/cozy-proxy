FeedbackView = require 'views/auth/feedback'


module.exports = class AuthView extends Mn.LayoutView

    tagName: 'form'

    className: ->
        @options.type

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


    initialize: (options) ->
        @options.next   ?= '/'
        @options.forgot = @options.type is 'login'

        @password = @$el.asEventStream('keyup blur', @ui.passwd)
                        .map (event) -> event.target.value
                        .toProperty('')
        @passwordEntered = @password.map (val) -> val.length > 0

        @submit = @$el.asEventStream 'click', @ui.submit
                      .doAction '.preventDefault'
                      .filter @passwordEntered
                      .map @password
                      .onValue @authenticate


    onRender: ->
        @passwordEntered.not().assign @ui.submit, 'attr', 'aria-disabled'
        @showChildView 'feedback', new FeedbackView
            forgot: @options.forgot
            model:  @model


    serializeData: ->
        data =
            username: window.username
            prefix:   @options.type


    authenticate: (password) =>
        data = JSON.stringify password: password
        auth = Bacon.fromPromise $.post @options.backend, data

        auth.map '.success'
            .onValue => window.location.pathname = @options.next

        @model.alert.plug auth.mapError
            status:  'error'
            title:   t "#{@options.type} wrong password title"
            message: t "#{@options.type} wrong password message"
