{LayoutView} = require 'backbone.marionette'


module.exports = class PasswordView extends LayoutView
    template: require '../templates/view_steps_password'

    events:
        'click button': 'doSubmit'


    initialize: (params={}) ->
        @actionsCreator = params.actionsCreator
        super params


    validate: ->
        return true


    getFormData: ->
        return {}


    doSubmit: (event) ->
        event?.preventDefault()

        data = @getFormData()

        # TODO: answer to this pattern question:
        # Should data be validated from:
        # - ./lib/onboarding/model/password/{props: {validate} }
        # - @validate() ?
        isStepValidated = @actionsCreator.doValidate data
        isFormValidated = @validate data

        if isStepValidated and isFormValidated
            @actionsCreator.doSubmit()
