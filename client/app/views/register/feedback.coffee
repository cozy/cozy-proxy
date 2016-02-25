###
Register feedback

A view that display the current step in the register flow
###

{ItemView} = require 'backbone.marionette'


module.exports = class RegisterFeedbackView extends ItemView

    template: require '../templates/view_register_feedback'


    onRender: ->
        # Check for each bullet point if it has the class of the current step.
        # If true, then toggle its selected state.
        @model.get('step')
            .map (value) -> return -> @classList.contains value
            .assign @$('li'), 'attr', 'aria-selected'

        # On last scree (welcome) screen, hide the feedback to only display
        # controls.
        @model.get('step')
            .map (step) -> /^welcome/.test step
            .assign @$el, 'attr', 'aria-hidden'
