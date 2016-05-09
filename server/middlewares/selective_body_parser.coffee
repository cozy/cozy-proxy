# Parse body only for non-proxied requests.
module.exports = (req, res, next) ->
    isNoAuthRoute = req.url.indexOf("/routes") isnt 0
    isNoAuthRoute = isNoAuthRoute and req.url.indexOf("/login") isnt 0
    isNoAuthRoute = isNoAuthRoute and req.url.indexOf("/password") isnt 0
    isNoAuthRoute = isNoAuthRoute and req.url.indexOf("/register") isnt 0
    isNoAuthRoute = isNoAuthRoute and req.url.indexOf("/device") isnt 0
    isNoAuthRoute = isNoAuthRoute and
        req.url.indexOf("/services/sharing") isnt 0
    isNoAuthRoute = isNoAuthRoute or
        req.url.indexOf("/services/sharing/replication") is 0

    if isNoAuthRoute then next()
    else
        # flag as parsed
        req._body = true

        # parse
        buf = ""
        req.setEncoding "utf8"
        req.on "data", (chunk) -> buf += chunk
        req.on "end", ->
            if buf.length > 0 and "{" isnt buf[0] and "[" isnt buf[0]
                return next new Error "invalid json"
            try
                if buf.length > 0
                    req.body = JSON.parse buf
                else
                    req.body = ""
                next()
            catch err
                console.log err
                next()
