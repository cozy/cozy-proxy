module.exports = class RegisterEmailView extends Mn.ItemView

    tagName: 'form'

    className: 'email'

    template: require 'views/templates/view_register_email'

    ui:
        legend: '.advanced legend'
        adv: '.advanced .content'


    initialize: ->
        @showAdv = @$el.asEventStream 'click', @ui.legend
                      .scan false, (visible) -> not visible


    onRender: ->
        @showAdv.not().assign @ui.adv, 'attr', 'aria-hidden'
