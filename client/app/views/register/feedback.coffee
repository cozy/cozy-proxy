module.exports = class RegisterFeedbackView extends Mn.ItemView

    template: require 'views/templates/view_register_feedback'

    modelEvents:
        'change:step': 'render'

