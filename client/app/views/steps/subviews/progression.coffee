{ItemView} = require 'backbone.marionette'


module.exports = class ProgressionView extends ItemView

    tagName: 'ol'

    template: require '../../templates/progression'
