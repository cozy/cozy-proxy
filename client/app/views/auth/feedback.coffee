_     = require 'underscore'
Bacon = require 'baconjs'

{ItemView} = require 'backbone.marionette'


module.exports = class AuthFeedbackView extends ItemView

    template: require '../templates/view_auth_feedback'

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
            sendLink = Bacon.$.asEventStream.call @$el, 'click', @ui.forgot
                .doAction '.preventDefault'
            @model.sendReset.plug sendLink
