###
Setup step view

This step display a counter as a progress bar that is:
- fake if the user do not import content (takes 8 seconds)
- indicates the import loading state, and have a minimal duration of 8 seconds
###

###
Helpers

This section declares top-level helpers
###

# Creates a stream from socket.io callbacks
socket = null

fromSocket = (event) ->
    # If the socket.io socket isn't available, open it
    unless socket
        socket = window.io window.location.origin,
            path:                 '/apps/import-from-google/socket.io'
            reconnectionDelayMax: 60000
            reconectionDelay:     2000
            reconnectionAttempts: 3

    # Exception: end events is named `contacts.end` for contacts, but
    # `events.end` for calendars. So we compute the end event name
    endEvent = if event is 'calendars' then 'events' else event

    # Creates a stream from the socket.io socket
    Bacon.fromBinder (sink) ->
        # Start the stream with a 0 value
        sink 0

        # On each socket event, send to the sink a progress percentage
        socket.on event, (data) ->
            sink Math.floor data.number / data.total * 100

        # On end event, send to the sink `100` and close the stream
        socket.on "#{endEvent}.end", ->
            sink 100
            sink new Bacon.End()

        # Returns an empty unsubscribe function
        return ->

# Returns the median value of arguments values
getProgress = ->
    sum = [].reduce.call arguments, ((memo, val) -> memo + val), 0
    sum / arguments.length


###
Setup View
###

module.exports = class RegisterSetupView extends Mn.ItemView

    className: 'setup'

    template: require 'views/templates/view_register_setup'

    ui:
        bar: 'progress'


    ###
    Initialize counter

    it takes care of the imported elements state (do we import something or not)
    ###
    initialize: ->
        @model.get 'imports'
            .onValue @initCounter


    ###
    Assign the internal counter property to the progress bar
    ###
    onRender: ->
        @progress.assign @ui.bar, 'val'


    ###
    Creates a counter property from
    - a timer of 8 seconds
    - each imports feedbacks
    ###
    initCounter: (imports) =>
        # Creates a simple stream that goes from 0 to 100 in 8 seconds
        timer = Bacon.interval(80, 1)
            .take 100
            .scan 0, (a, b) -> a + b

        # If there's imports, the `progress` property is a median of the timer
        # and imports progress ; otherwise it's just a reference to the timer
        if imports
            args = [getProgress, timer.toProperty()]
            if 'contacts' in imports
                args.push fromSocket('contacts').toProperty()
            if 'calendars' in imports
                args.push fromSocket('calendars').toProperty()

            @progress = Bacon.combineWith.apply Bacon, args
        else
            @progress = timer.toProperty()

        # Creates an `end` event that is streamed when the progress is `100`,
        # mapped to the `nextStep` property. This stream is plugged to the
        # setBusPlug stream (i.e. when progress is `100` we go to the next step)
        end = @progress.filter (n) -> n >= 100
            .map @model.steps['setup'].next
        @model.setStepBus.plug end
