###
App Layout

Attach itself to the `[role=application] DOM node and declares the application
main region for its subviews.
###

module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layout_app'

    el: '[role=application]'

    regions:
        content: '.container'
