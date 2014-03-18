###
App usage tracking
###

# Global
appTracker = {}
if not process.env.NODE_ENV? or process.env.NODE_ENV is "development"
    TIMING = 10000 # 10s
else
    TIMING = 5 * 60 * 1000 # 5 minutes

UseTracker = require '../models/usetracker'

# Exporting as Express middleware
module.exports = (req, res, next) ->
    url = req.url

    # only if an app is requested
    if url.indexOf("/apps") is 0
        arrayUrl = url.split '/'
        appName = arrayUrl[2]
        date = new Date()

        # Tracking logic
        if not appTracker[appName]?
            appTracker[appName] =
                timer: date.getTime()
                timeout: null

        appInfo = appTracker[appName]
        clearTimeout appInfo.timeout
        # When the timeout proc, the session is considered terminated
        appInfo.timeout = setTimeout ->
            dateStart = appInfo.timer
            dateEnd = new Date().getTime()
            data =
                app: appName
                dateStart: new Date dateStart
                dateEnd: new Date dateEnd
                duration: dateEnd-dateStart
            delete appTracker[appName]
            UseTracker.create data, (err, res, body) ->
                console.log "Couldn't add app tracking info -- #{err}" if err?
        , TIMING

    next()
