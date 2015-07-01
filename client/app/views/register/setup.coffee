module.exports = class RegisterSetupView extends Mn.ItemView

    className: 'setup'

    template: require 'views/templates/view_register_setup'


    initialize: ->
        @model.setStepBus.plug Bacon.later 8000, @model.steps['setup'].next
