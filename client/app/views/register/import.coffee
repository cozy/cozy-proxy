module.exports = class RegisterImportView extends Mn.ItemView

    className: 'import'

    template: require 'views/templates/view_register_import'

    ui:
        google: '#import-google'


    initialize: ->
        stream = @$el.asEventStream 'click', @ui.google
                     .doAction '.preventDefault'
                     .map (e) -> e.target.href.split('=')[1]
        @model.setStepBus.plug stream
