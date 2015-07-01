module.exports = class RegisterSetupView extends Mn.ItemView

    className: 'setup'

    template: require 'views/templates/view_register_setup'

    ui:
        bar: 'progress'


    initialize: ->
        @timer = Bacon.interval(80, 1)
                      .take 100
                      .scan 0, (a, b) -> a + b
        end = @timer.filter (n) -> n >= 100
                    .map @model.steps['setup'].next
        @model.setStepBus.plug end


    onRender: ->
        @timer.assign @ui.bar, 'val'
