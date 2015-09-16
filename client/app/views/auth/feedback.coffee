module.exports = class AuthFeedbackView extends Mn.ItemView

    template: require 'views/templates/view_auth_feedback'

    ui:
        forgot: 'a.forgot'


    serializeData: ->
        _.extend @model.toJSON(),
            forgot: @options.forgot
            prefix: @options.prefix


    initialize: ->
        @model.get('alert').subscribe @render

        @model.alert
            .map (res) ->
                if res.status then res.status else null
            .assign @$el, 'attr', 'class'

        if @options.forgot
            sendLink = @$el.asEventStream 'click', @ui.forgot
                .doAction '.preventDefault'
            @model.sendReset.plug sendLink
