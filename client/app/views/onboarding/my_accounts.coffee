{LayoutView} = require 'backbone.marionette'

module.exports = class MyAccountsView extends LayoutView
    template: require '../templates/my_accounts'

    ui:
        next: '.controls .next'

    events:
        'click @ui.next': 'onSubmit'

    initialize: (options) ->
        super options
        @myAccountsUrl = options.myAccountsUrl


    serializeData: ->
        data = super()
        data.myAccountsUrl = @myAccountsUrl
        return data

    onSubmit: (event) ->
        event.preventDefault()
        @model.submit()
