module.exports = class RegisterFeedbackView extends Mn.ItemView

    template: require 'views/templates/view_register_feedback'


    onRender: ->
        @model.get('step').map (value) -> return -> @classList.contains value
                          .assign @$('li'), 'attr', 'aria-selected'

        @model.get('step').map (step) -> /^welcome/.test step
                          .assign @$el, 'attr', 'aria-hidden'
