### Middlewares ###

mime = (req) ->
  str = req.headers['content-type'] || ''
  return str.split(';')[0]

# Parse body only for non-proxied requests.
exports.selectiveBodyParser = (req, res, next) ->
    if req.url.indexOf("/routes") != 0 and req.url.indexOf("/login") != 0 and req.url.indexOf("/password") != 0 and req.url.indexOf("/register") != 0
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
