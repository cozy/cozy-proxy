module.exports = class AuthFeedbackView extends Mn.ItemView

    template: require 'views/templates/view_auth_feedback'

    ui:
        forgot: 'a.forgot'


    serializeData: ->
        _.extend @model.toJSON(), forgot: @options.forgot


    initialize: ->
        @model.get('alert').subscribe @render
        @model.get('recover').subscribe @render

        @model.alert.map '.status'
                    .assign @$el, 'attr', 'class'

        forgot = @$el.asEventStream 'click', @ui.forgot
                     .doAction '.preventDefault'
                     .subscribe @sendResetPassword


    sendResetPassword: =>
        reset = Bacon.fromPromise $.post '/login/forgot'

        @model.alert.plug reset.map
            status:  'success'
            title:   t 'login recover sent title'
            message: t 'login recover sent message'

        reset.map t 'login recover again'
             .onValue (text) => @ui.forgot.text text
