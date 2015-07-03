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

        @password = @$el.asEventStream('focus keyup blur', @ui.passwd)
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
        @ui.passwd.asEventStream 'focus'
                  .assign @ui.passwd[0], 'select'

        @model.isBusy.assign @ui.submit, 'attr', 'aria-busy'

        @showChildView 'feedback', new FeedbackView
            forgot: @options.forgot
            model:  @model

        setTimeout =>
            @ui.passwd.focus()
        , 100


    serializeData: ->
        data =
            username: window.username
            prefix:   @options.type


    authenticate: (password) =>
        @model.isBusy.push true
        data = JSON.stringify password: password
        req = Bacon.fromPromise $.post @options.backend, data

        @model.isBusy.plug req.mapEnd false

        req.map '.success'
            .onValue => window.location.pathname = @options.next

        @model.alert.plug req.mapError
            status:  'error'
            title:   t "#{@options.type} wrong password title"
            message: t "#{@options.type} wrong password message"
