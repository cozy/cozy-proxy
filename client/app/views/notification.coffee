{ItemView} = require 'backbone.marionette'

module.exports = class NotificationView extends ItemView
    template: require './templates/notification'

    displayTime: 6000

    ui:
        notification: '.coz-notification'
        title: '.coz-notification-title'
        message: '.coz-notification-message'


    onRender: () ->
        @hidden = @ui.notification.attr 'aria-hidden'

        @$el.on 'click', (event) =>
            event.preventDefault()
            @hide()


    show: ({title, message}) =>
        return if not @hidden

        @hidden = false
        @ui.title.text t title
        @ui.message.text t message

        @ui.notification.attr 'aria-hidden', false

        setTimeout @hide, @displayTime


    hide: () =>
        return if @hidden

        @hidden = true
        @ui.notification.attr 'aria-hidden', true
