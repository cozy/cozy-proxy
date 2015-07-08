###
Welcome (last) step view

This view display the welcome wording and permit to pass to the login screen
###

module.exports = class RegisterWelcdomeView extends Mn.ItemView

    className: 'welcome'

    template: require 'views/templates/view_register_welcome'
