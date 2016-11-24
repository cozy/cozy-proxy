StepView = require '../step'
_ = require 'underscore'


module.exports = class InfosView extends StepView
    template: require '../templates/view_steps_infos'

    ui:
        next: '.controls .next'

    events:
        'click @ui.next': 'onSubmit'

    fields: [
        'public_name',
        'email',
        'timezone'
    ]

    # Step may contain errors, for example when data fetching has failed.
    onRender: ->
        error = @model.get 'error'
        if error
            @showErrors(message: error)


    serializeData: ->
        _.extend super,
            id: "#{@model.get 'name'}-figure"
            figureid: require '../../assets/sprites/icon-clipboard.svg'
            timezones: require '../../lib/timezones'


    getFormData: () ->
        # We store inputs in an array with identifier, mainly because it is
        # useful for error management
        @$inputs ?= @fields.reduce (inputs, field) =>
            inputs[field] = @$ "\##{field}"
            return inputs
        , []

        # Alternate ending :
        # return fields.reduce (data, field) =>
        #     data[field] = @$inputs[field].val()
        #     return data
        # , {}
        # but this is more readable
        return {
            public_name: @$inputs['public_name'].val()
            email: @$inputs['email'].val()
            timezone: @$inputs['timezone'].val()
        }


    onSubmit: (event) ->
        event.preventDefault()
        @model
            .submit @getFormData()
            .then null, (error) =>
                @showErrors error


    # Add `error` class to field's input and set error message in related
    # `.error-label` element.
    #
    # @param field: field's name
    # @param message: error message
    showError: (field, message) ->
        return unless field in @fields

        @$inputs[field]?.addClass('error')

        @$errorPlaceholders[field] ?= @$ ".error-label[data-for=#{field}]"
        @$errorPlaceholders[field]?.text t message
            .show()


    # Remove `error` class from field's input, empty and hide related
    # `.error-label` element
    #
    # @param field: field's name
    hideError: (field) ->
        return unless field in @fields

        @$errorPlaceholders?[field]?.text('').hide()
        @$inputs?[field]?.removeClass('error')


    # @param Error Object
    #   Expected format is :
    #   {
    #       message: main error message
    #       [errors: array containing field name as key and error message
    #            as value]
    #   }
    showErrors: ({message, errors}) =>

        if message
            @$errorMessagePlaceholder ?= @$ '.errors'
            @$errorMessagePlaceholder.text(t(message)).show()
        else
            @$errorMessagePlaceholder?.text('').hide()

        @$errorPlaceholders ?= []
        @fields.forEach (field) =>
            if errors and errors[field]
                @showError field, errors[field]
            else
                # We hide errors now to have a smoother rendering
                @hideError field
