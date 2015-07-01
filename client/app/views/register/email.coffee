getPropertiesFromEls = ($els) ->
    getValue = (el) ->
        if el.type is 'checkbox' then el.checked
        else el.value

    $els.map ->
        $(@).asEventStream 'keyup blur'
            .map (event) -> getValue event.target
            .toProperty getValue @
    .get()


module.exports = class RegisterEmailView extends Mn.ItemView

    tagName: 'form'

    className: 'email'

    template: require 'views/templates/view_register_email'

    ui:
        legend:   '.advanced legend'
        adv:      '.advanced .content'
        required: 'input[required]'
        inputs:   'input'


    initialize: ->
        @isEmail = @model.get('step').map (step) -> step is 'email'
        @showAdv = @$el.asEventStream 'click', @ui.legend
                      .scan false, (visible) -> not visible


    onRender: ->
        @showAdv.not().assign @ui.adv, 'attr', 'aria-hidden'
        @showAdv.assign @ui.legend, 'attr', 'aria-hidden'

        # required inputs interactions
        requiredInputs = getPropertiesFromEls @ui.required
        requiredAll = _.reduce requiredInputs, (memo, property) ->
            memo.and property.map (value) -> value.length > 0
        , Bacon.constant true

        @model.nextButtonLabel.plug requiredAll.map (bool) ->
            if bool then 'add email' else 'skip'

