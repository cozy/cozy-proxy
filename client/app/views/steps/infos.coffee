StepView = require '../step'
_ = require 'underscore'


module.exports = class InfosView extends StepView
    template: require '../templates/view_steps_infos'

    ui:
        next: '.controls .next'

    events:
        'click @ui.next': 'onSubmit'


    serializeData: ->
        _.extend super,
            id: "#{@model.get 'name'}-figure"
            figureid: require '../../assets/sprites/icon-clipboard.svg'
            timezones: require '../../lib/timezones'


    getFormData: () ->
        @$publicName ?= @$ '#public_name'
        @$email ?= @$ '#email'
        @$timezone ?= @$ '#timezone'

        return {
            public_name: @$publicName.val()
            email: @$email.val()
            timezone: @$timezone.val()
        }


    onSubmit: (event)->
        event.preventDefault()
        @model.submit(@getFormData())
