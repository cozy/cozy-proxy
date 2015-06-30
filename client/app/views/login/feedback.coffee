module.exports = class LoginFeedbackView extends Mn.ItemView

    template: require 'views/templates/view_login_feedback'

    ui:
        forgot: 'a.forgot'

    # events:
        # 'click @ui.forgot': (e) -> e.preventDefault()


    initialize: ->
        @model.get('alert').subscribe @render
        @model.get('recover').subscribe @render

        @model.alert.map '.status'
                    .assign @$el, 'attr', 'class'

        forgot = @$el.asEventStream 'click', @ui.forgot
                     .doAction '.preventDefault'
                     .onValue (e) -> console.debug e
            # .doAction '.preventDefault'
            # .doAction =>
            #     console.debug arguments
            #     @model.alert.push
            #         status:  'success'
            #         title:   'login recover sent title'
            #         message: 'login recover sent message'

