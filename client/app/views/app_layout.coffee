module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layout_app'

    el: '[role=application]'

    regions:
        content: '.container'
