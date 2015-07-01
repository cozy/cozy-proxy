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
        @isEmail = @model.get('step').map (step) -> step in ['email', 'setup']
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

        # inputs submission
        inputs = getPropertiesFromEls @ui.inputs
        Bacon.combineAsArray inputs
             .filter requiredAll
             .sampledBy @model.nextClickStream
             .filter @isEmail
             .onValue @onSubmit


    onSubmit: (values) ->
        data =
            email:    values[0]
            password: values[1]
            server:   values[2]
            port:     values[3]
            ssl:      values[4]
            username: values[5]
        req = Bacon.fromPromise $.post '/register/email', JSON.stringify data
