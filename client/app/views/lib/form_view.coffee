###
Form View

This is a top-level class that contains helpers for FormViews. It is not
intended to be used directly.
###

Bacon = require 'baconjs'
$     = require 'jquery'

{ItemView} = require 'backbone.marionette'

asEventStream = Bacon.$.asEventStream


module.exports = class FormView extends ItemView

    tagName: 'form'

    ui:
        labels:   'label.with-input'
        inputs:   ':input'


    ###
    Prepare internal streams
    ###
    constructor: ->
        super

        # inputsStream is a stream containing all inputs events, delegated
        @inputsStream = asEventStream.call @$el, 'keyup blur change', @ui.inputs
        # submitStream receive the submit event, prevent the natural submission,
        # and is filtered onto the next button enable state (form can't be
        # submitted if the control is disabled)
        @submitStream = asEventStream.call @$el, 'submit'
            .doAction '.preventDefault'
            .filter => @model.get('nextControl').map '.enabled'


    ###
    Initialize the form streams and properties

    This helper needs to be explicitely called in the child-class `onRender`
    method.
    ###
    initForm: ->
        # Prepare a template that contains all fields properties
        inputs   = {}
        # Prepare a property that describes if all required fields are filled
        required = Bacon.constant true

        # A simple helper to get the value in regard of input type
        getValue = (el) ->
            if el.type is 'checkbox' then el.checked else el.value

        # For each input in the form…
        @ui.inputs.map (index, el) =>
            # React to the inputStream (which is a delegate stream from the top
            # `form` element), filter to ensure the target is the current input
            # and get its value.
            property = @inputsStream.map '.target'
                .filter (target) -> target is el
                .map getValue
                .toProperty getValue el
            # STores the property in the template
            inputs[el.name] = property
            # If the field is required, then combine its value to all others
            # required fields
            required = required.and(property.map (val) -> !!val) if el.required

        # Combine a `form` property that is a complex property combined from the
        # template, which is useful to get all form fields values in the stream.
        # We sampled the property by the submit stream (i.e. the form property
        # is converted as a stream which trigger a message each time the submit
        # event occurs or the next control button is clicked).
        # The stream is filtered by required to ensure the form is submitted
        # only if required inputs are filled.
        @model.setStepBus.plug @submitStream.map @model.get 'nextStep'
        @form = Bacon.combineTemplate inputs
            .sampledBy @model.nextClickStream.merge @submitStream
            .filter required

        # Exposes the required property into the prototype
        @required = required


    ###
    Initialize the errors streams and actions

    This helper needs to be explicitely called in the child-class `onRender`
    method.
    ###
    initErrors: ->
        # Simple helper to get a boolean from value
        isTruthy  = (value) -> !!value
        # Simple helper that creates an error message DOM node
        createMsg = (msg) -> $('<p/>', {class: 'error', text: msg})

        # Remove all errors messages into the DOM when receive new errors (e.g.
        # user just submitted a new form also containing errors). We filter on
        # errors te ensure the signal contains new errors.
        @model.errors
            .filter (errors) -> !!errors
            .subscribe =>
                @ui.labels.find('.error').remove()

        # For each couple of key: message in the error stream…
        for name, property of @errors
            # get the correct DOM element that host the faulty input
            $el = @ui.labels.filter("[for=preset-#{name}]")
            # Map the message value to its invalid state
            property.map isTruthy
                .assign $el, 'attr', 'aria-invalid'
            # And creates and append to it the error message
            property.filter(isTruthy).map createMsg
                .assign $el, 'append'
