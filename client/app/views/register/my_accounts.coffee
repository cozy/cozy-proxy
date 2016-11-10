{LayoutView} = require 'backbone.marionette'

module.exports = class MyAccountsView extends LayoutView
    template: require '../templates/my_accounts'


    initialize: (options) ->
        super options
        @myAccountsUrl = options.myAccountsUrl


    serializeData: ->
        data = super()
        data.myAccountsUrl = @myAccountsUrl
        return data
