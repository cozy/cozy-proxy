### Middlewares ###

mime = (req) ->
    str = req.headers['content-type'] || ''
    return str.split(';')[0]

# Parse body only for non-proxied requests.
exports.selectiveBodyParser = (req, res, next) ->
    isNoAuthRoute = req.url.indexOf("/routes") != 0
    isNoAuthRoute = isNoAuthRoute and req.url.indexOf("/login") != 0
    isNoAuthRoute = isNoAuthRoute and req.url.indexOf("/password") != 0
    isNoAuthRoute = isNoAuthRoute and req.url.indexOf("/register") != 0

    if isNoAuthRoute
        next()
    else
        # check Content-Type
        #return next() unless "application/json" is mime(req)

        # flag as parsed
        req._body = true

        # parse
        buf = ""
        req.setEncoding "utf8"
        req.on "data", (chunk) ->
            buf += chunk
        req.on "end", ->
            if buf.length > 0 and "{" isnt buf[0] and "[" isnt buf[0]
                return next(new Error("invalid json"))
            try
                if buf.length > 0
                    req.body = JSON.parse(buf)
                else
                    req.body = ""
                next()
            catch err
                #err.body = buf
                #err.status = 400
                #next err
                console.log err
                next()


###
App usage tracking
###

# Global
appTracker = {}
if not process.env.NODE_ENV? or process.env.NODE_ENV is "development"
    timing = 10000 # 10s
else
    timing = 5 * 60 * 1000 # 5 minutes

# Data system process
Client = require('request-json').JsonClient
client = new Client "http://localhost:9101/"
authentifiedEnvs = ['test', 'production']
if process.env.NODE_ENV in authentifiedEnvs
    client.setBasicAuth process.env.NAME, process.env.TOKEN

saveTrackingInfo = (info) ->
    info.docType = "UseTracker"
    client.post 'data/', info, (err, res, body) ->
        console.log "Couldn't add app tracking info -- #{err}" if err?

# Express middleware
exports.tracker = (req, res, next) ->
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
        appInfo.timeout = setTimeout () ->
            dateStart = appInfo.timer
            dateEnd = new Date().getTime()
            info =
                app: appName
                dateStart: new Date dateStart
                dateEnd: new Date dateEnd
                duration: dateEnd-dateStart
            delete appTracker[appName]
            saveTrackingInfo info
        , timing

    next()
