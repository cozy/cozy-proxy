{LayoutView} = require 'backbone.marionette'

module.exports = class InfosView extends LayoutView
    template: require '../templates/view_steps_infos'

    events:
        'click button': 'onSubmit'

    onSubmit: (event)->
        @model.submit()
