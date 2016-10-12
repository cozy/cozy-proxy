###
App Layout

Attach itself to the `[role=application] DOM node and declares the application
main region for its subviews.
###

# Normalize styles
require 'normalize.css/normalize.css'


{LayoutView} = require 'backbone.marionette'


module.exports = class AppLayout extends LayoutView

    template: require './templates/layout_app'

    el: '[role=application]'

    regions:
        content: '.container'
