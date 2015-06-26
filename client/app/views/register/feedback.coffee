module.exports = class RegisterFeedbackView extends Mn.ItemView

    template: require 'views/templates/view_register_feedback'


    onBeforeShow: ->
        @model.get 'step'
        .map (value) -> return -> @.classList.contains value
        .assign @$('li'), 'attr', 'aria-selected'
