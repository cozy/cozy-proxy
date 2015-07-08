###
Setup step view

This step display a counter as a progress bar that is:
- fake if the user do not import content (takes 8 seconds)
- indicates the import loading state, and have a minimal duration of 8 seconds
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
        @model.get('previousStep')
            .map (step) -> step is 'import_google'
            .onValue @initCounter


    onRender: ->
        @progress.assign @ui.bar, 'val'


    initCounter: (leaveGoogle) =>
        timer = Bacon.interval(80, 1)
            .take 100
            .scan 0, (a, b) -> a + b

        if leaveGoogle
            @socket = window.io window.location.origin,
                path:                 '/apps/leave-google/socket.io'
                reconnectionDelayMax: 60000
                reconectionDelay:     2000
                reconnectionAttempts: 3

            cards = @getSocketProperty 'contacts'
            cals  = @getSocketProperty 'calendars'
            time  = timer.toProperty()

            @progress = Bacon.combineWith @getProgress, cards, cals, time
        else
            @progress = timer

        end = @progress.filter (n) -> n >= 100
            .map @model.steps['setup'].next
        @model.setStepBus.plug end


    getSocketProperty: (event) ->
        endEvent = if event is 'calendars' then 'events' else event

        stream = Bacon.fromBinder (sink) =>
            sink 0
            @socket.on event, (data) ->
                sink Math.floor data.number / data.total * 100

            @socket.on "#{endEvent}.end", ->
                sink 100
                sink new Bacon.End()

            return ->

        stream.toProperty()


    getProgress: (cards, cals, time) ->
        (cards + cals + time) / 3
