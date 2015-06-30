FeedbackView = require 'views/login/feedback'


module.exports = class LoginView extends Mn.LayoutView

    tagName: 'form'

    className: 'login'

    template: require 'views/templates/view_login'

    regions:
        'feedback': '.feedback'

    ui:
        passwd: '#login-password'
        signin: '.controls button[type=submit]'


    initialize: (options) ->
        @next = @options.next or '/'

        @password = @$el.asEventStream('keyup blur', @ui.passwd)
                        .map (event) -> event.target.value
                        .toProperty('')
        @passwordEntered = @password.map (val) -> val.length > 0

        @signin = @$el.asEventStream 'click', @ui.signin
                      .doAction '.preventDefault'
                      .filter @passwordEntered
                      .map @password
                      .onValue @authenticate


    onRender: ->
        @passwordEntered.not().assign @ui.signin, 'attr', 'aria-disabled'

        @showChildView 'feedback', new FeedbackView model: @model


    serializeData: ->
        data =
            username: window.username


    authenticate: (password) =>
        data = JSON.stringify password: password
        auth = Bacon.fromPromise($.post '/login', data)

        auth.map '.success'
            .onValue (success) =>
                window.location.pathname = @next

        @model.alert.plug auth.mapError
            status: 'error'
            title: 'login wrong password title'
            message: 'login wrong password message'
