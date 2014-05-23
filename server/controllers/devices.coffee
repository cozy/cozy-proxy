passport = require 'passport'
deviceManager = require '../models/device'
{getProxy} = require '../lib/proxy'

# helper functions
extractCredentials = (header) ->
    if header?
        authDevice = header.replace 'Basic ', ''
        authDevice = new Buffer(authDevice, 'base64').toString 'ascii'
        return authDevice.split ':'
    else
        return ["", ""]

getCredentialsHeader = ->
    credentials = "#{process.env.NAME}:#{process.env.TOKEN}"
    basicCredentials = new Buffer(credentials).toString 'base64'
    return "Basic #{basicCredentials}"

# controller actions
module.exports.management = (req, res, next) ->

    authenticator = passport.authenticate 'local', (err, user) ->
        if err
            console.log err
            next err
        else if user is undefined or not user
            error = new Error "Bad credentials"
            error.status = 401
            next error
        else
            # Send request to the Data System
            req.headers['authorization'] = getCredentialsHeader()
            res.end = -> deviceManager.update()
            getProxy().web req, res, target: process.env.DATASYSTEM_URL

    # Authenticate the request
    [username, password] = extractCredentials req.headers['authorization']

    # Initialize user
    user = {}
    user.body = password: password

    req.headers['authorization'] = undefined
    # Check if request is authenticated
    authenticator user, res

module.exports.replication = (req, res, next) ->

    # Authenticate the request
    [username, password] = extractCredentials req.headers['authorization']
    if deviceManager.isAuthenticated username, password
        # Add his creadentials for CouchDB
        if process.env.NODE_ENV is "production"
            req.headers['authorization'] = getCredentialsHeader()

        # Forward request to Couch
        # the request didn't go through the DS because for some unknown
        # reason, the double proxy was failing. We should try again with
        # the new node-http-proxy version.
        # That would make a device an application that is not running on
        # the Cozy itself which is awesome because it would be easy to
        # add a permission layer and makes Cozy a true open platform
        # (easy desktop/mobile clients)
        getProxy().web req, res, target: process.env.COUCH_URL
    else
        error.status = 401
        error = new Error "Request unauthorized"
        next error
