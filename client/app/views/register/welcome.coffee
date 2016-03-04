###
Welcome (last) step view

This view display the welcome wording and permit to pass to the login screen
###

{ItemView} = require 'backbone.marionette'


module.exports = class RegisterWelcdomeView extends ItemView

    className: 'welcome'

    template: require '../templates/view_register_welcome'
