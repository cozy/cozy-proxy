###
Setup step view

This step display a counter as a progress bar that is:
- fake if the user do not import content (takes 8 seconds)
- indicates the import loading state, and have a minimal duration of 8 seconds
###

_     = require 'underscore'
$     = require 'jquery'
Bacon = require 'baconjs'
io    = require 'socket.io-client'

{ItemView} = require 'backbone.marionette'

###
Helpers

This section declares top-level helpers
###

# Creates a stream from socket.io callbacks
socket = null

fromSocket = (event) ->
    # If the socket.io socket isn't available, open it
    unless socket
        socket = io window.location.origin,
            path:                 '/apps/import-from-google/socket.io'
            reconnectionDelayMax: 60000
            reconectionDelay:     2000
            reconnectionAttempts: 3

    # Exception: end events is named `contacts.end` for contacts, but
    # `events.end` for calendars. So we compute the end event name
    endEvent = if event is 'calendars' then 'events' else event

    # Creates a stream from the socket.io socket
    Bacon.fromBinder (sink) ->
        onEnd = ->
            sink 100
            sink new Bacon.End()

        onError = ->
            sink 100
            sink new Bacon.Error 'import error'

        # Raise an error if the server isnt responding for 15 seconds
        preventErrTimeout = _.debounce onError, 15000

        # Start the stream with a 0 value
        sink 0

        # Raise an error if the socket client can't connect to the server
        # (leave 2.5 seconds to let socket.io trying one reconnection)
        setTimeout ->
            onError() if socket.disconnected
        , 2500

        # On each socket event, send to the sink a progress percentage
        socket.on event, (data) ->
            sink Math.floor data.number / data.total * 100
            preventErrTimeout()

        # On end event, send to the sink `100` and close the stream
        socket.on "#{endEvent}.end", onEnd
        socket.on 'ok', onEnd
        socket.on 'invalid token', onError

        # Returns an empty unsubscribe function
        return ->


###
Setup View
###

module.exports = class RegisterSetupView extends ItemView

    className: 'setup'

    template: require '../templates/view_register_setup'

    ui:
        bar: 'progress'


    ###
    Initiliaze counter - it takes care of the imported elements state (do we
    import something or not)
    ###
    onBeforeRender: ->
        @model.get('imports').onValue @initCounter


    ###
    Assign the internal counter property to the progress bar
    ###
    onRender: ->
        @progress.assign @ui.bar, 'val'


    ###
    When an error occurs, give feedback to the user (and prevent duplicate error
    box if there's already one)
    ###
    onError: =>
        return if @$('.error').length
        text = window.t 'import error'
        @ui.bar.after $ '<p/>', class: 'error', text: text


    ###
    Creates a counter property from
    - a timer of 8 seconds
    - each imports feedbacks
    ###
    initCounter: (imports) =>
        # Creates a simple stream that goes from 0 to 100 in 8 seconds
        timer = ->
            Bacon.interval(80, 1)
                .take 100
                .scan 0, (a, b) -> a + b
                .toProperty()

        # If there's imports, the `progress` property is a median of the timer
        # and imports progress ; otherwise it's just a reference to the timer
        if imports
            # Returns the median value of arguments values
            getProgress = ->
                sum = [].reduce.call arguments, ((memo, val) -> memo + val), 0
                Math.floor sum / arguments.length

            streams = imports.map (datasource) ->
                fromSocket(datasource).toProperty()

            @progress = Bacon.combineWith getProgress, timer(), streams...
            @progress.onError @onError
        else
            @progress = timer()

        # Creates an `end` event that is streamed when the progress is `100`,
        # mapped to the `nextStep` property. This stream is plugged to the
        # setBusPlug stream (i.e. when progress is `100` we go to the next step)
        end = @progress.filter (n) -> n >= 100
            .map @model.steps['setup'].next
        @model.setStepBus.plug end
