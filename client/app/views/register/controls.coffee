module.exports = class RegisterControlsView extends Mn.ItemView

    template: require 'views/templates/view_register_controls'

    ui:
        'next': 'a.btn'

    onBeforeShow: ->
        @model.get('nextStep')
        .map (value) =>
            return "#{@ui.next.attr('href').split('=')[0]}=#{value}"
        .assign @ui.next, 'attr', 'href'
