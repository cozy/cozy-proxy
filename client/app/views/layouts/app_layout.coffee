module.exports = class AppLayout extends Backbone.Marionette.LayoutView

    template: require 'views/templates/layout_app'

    el: '#app'

    regions:
        content:  '#popup .content'
