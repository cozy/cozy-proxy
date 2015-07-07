module.exports = class FormView extends Mn.ItemView

    tagName: 'form'

    ui:
        labels:   'label.with-input'
        inputs:   'label input'


    constructor: ->
        super
        
        @inputsStream = @$el.asEventStream 'keyup blur change', @ui.inputs
        @submitStream = @$el.asEventStream 'submit'
            .doAction '.preventDefault'
            .filter @model.get('nextControl').map '.enabled'


    initForm: ->
        inputs   = {}
        required = Bacon.constant true

        getValue = (el) ->
            if el.type is 'checkbox' then el.checked else el.value

        @ui.inputs.map (index, el) =>
            property = @inputsStream.map '.target'
                .filter (target) -> target is el
                .map getValue
                .toProperty getValue el
            inputs[el.name] = property
            required = required.and(property.map (val) -> !!val) if el.required


        @form = Bacon.combineTemplate inputs
            .sampledBy @model.nextClickStream.merge @submitStream

        @required = required


    initErrors: ->
        isTruthy  = (value) -> !!value
        createMsg = (msg) -> $('<p/>', {class: 'error', text: msg})

        @model.errors
            .subscribe =>
                @ui.labels.find('.error').remove()

        for name, property of @errors
            $el = @ui.labels.filter("[for=preset-#{name}]")
            property.map isTruthy
                .assign $el, 'attr', 'aria-invalid'
            property.filter(isTruthy).map createMsg
                .assign $el, 'append'
