deviceManager = require '../models/device'
request = require('request-json')
exec = require('child_process').exec
controllerClient = request.newClient('http://localhost:9002')

# helper functions
extractCredentials = (header) ->
    if header?
        authDevice = header.replace 'Basic ', ''
        authDevice = new Buffer(authDevice, 'base64').toString 'ascii'
        return authDevice.split ':'
    else
        return ["", ""]

recoverDiskSpace = (cb) ->
    exec 'df -h', (err, rawDiskSpace) ->
        if err
            cb "Error while retrieving disk space -- #{err}"
        else
            data = {}
            lines = rawDiskSpace.split '\n'
            for line in lines
                line = line.replace /[\s]+/g, ' '
                lineData = line.split ' '

                if lineData.length > 5 and lineData[5] is '/'
                    freeSpace = lineData[3].substring 0, lineData[3].length - 1
                    usedSpace = lineData[2].substring 0, lineData[2].length - 1
                    totalSpace = lineData[1].substring 0, lineData[1].length - 1

                    data.freeDiskSpace = freeSpace
                    data.usedDiskSpace = usedSpace
                    data.totalDiskSpace = totalSpace
            cb null, data

getAuthController = ->
    if process.env.NODE_ENV is 'production'
        try
            token = process.env.TOKEN
            token = token.split('\n')[0]
            return token
        catch err
            console.log err.message
            console.log err.stack
            return null
    else
        return ""


module.exports.getSpace = (req, res, next) ->
    # Authenticate the device
    [username, password] = extractCredentials req.headers['authorization']
    deviceManager.isAuthenticated username, password, (auth) ->
        if auth
            # Recover disk space with controller
            controllerClient.setToken getAuthController()
            controllerClient.get 'diskinfo', (err, resp, body) ->
                # If error, recover disk space with command df -H
                if err or resp.statusCode isnt 200
                    recoverDiskSpace (err, body) ->
                        if err?
                            error = new Error err
                            error.status = 500
                            next error
                        else
                            res.status(200).send diskSpace: body
                else
                    res.status(200).send diskSpace: body
        else
            error = new Error "Request unauthorized"
            error.status = 401
            next error
