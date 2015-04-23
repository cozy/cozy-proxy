fs = require 'fs-extra'
async = require 'async'
pushover = require 'pushover'
gitListener = require 'git-emit'
mkdirp = require 'mkdirp'
exec = require('child_process').exec

User = require '../models/user'

# Authenticate all the connections to the Git repository via Basic HTTP
# authentication, so that the Git client prompt for username and password.
#
# We do not use passport in that case because we want the user to input the
# email as its username (along with its Cozy password). Besides, the server
# needs to send a response with a "WWW-Authenticate" header.
authenticate = (header, callback) ->
    if not header
        return callback false

    credentials = new Buffer(header.split(' ')[1], 'base64').toString 'ascii'
    [email, password] = credentials.split ':'
    User.first (err, user) ->
        if err? or not user?
            callback false
        else
            bcrypt.compare password, user.password, (err, result) ->
                if err? or not result
                    callback false
                else
                    callback user.email is email


# Handle HTTP requests to Git repositories via pushover
appsDir = '/usr/local/cozy/apps'
repos = pushover appsDir,
  autocreate: true
  checkout: true


# Actions that will be triggered on the 'update' Git hook
# Client is waiting for an answer at this point, so we need to call
# `update.accept()` at the end
updateRepo = (update, appRepo) ->
    exec "git reset --hard", cwd: appRepo, ->
        update.accept() if update?


# Repo has already been created by pushover at this point.
# We just need to configure it so that client won't receive an undesired error
# Also, we need to remove ".git" from repository's path
configureNewRepo = (appRepo) ->
    exec "git config receive.denyCurrentBranch ignore"
    , cwd: "#{appRepo}.git", ->
        fs.move "#{appRepo}.git", appRepo, (err) ->
            callback err if err
            updateRepo(null, appRepo)

            # Ensure that a gitListener is active on this repository
            gitListener("#{appRepo}/.git").on('update', updateRepo)


# Add Git hook listeners for each app that already exists
fs.readdir appsDir, (err, apps) ->
    for app in apps
        if fs.existsSync "#{appsDir}/#{app}/.git"
            gitListener("#{appsDir}/#{app}/.git").on('update', updateRepo)
            exec "git config receive.denyCurrentBranch ignore"
            , cwd: "#{appsDir}/#{app}"


#
#  Serve the repository
#
#  - If we receive a GET request, pushover just serves the files in
#    `/usr/local/cozy/apps/<APP>/.git` as plain files
#
#  - If we receive a POST request (corresponding to a push), we:
#     * Create the repository if it does not exist yet
#     * Configure it so that we have a copy of the working tree in it
#       (by default server repositories are bare)
#     * Accept the push
#     * Update the working tree
#     * Use the `update` Git hook caught by git-emit to proceed to the
#       application deployment and send information back to the client.
#
#  Both actions require authentication, the repository is considered
#  private.
#
module.exports.serveRepo = (req, res, next) ->

    authenticate req.headers['authorization'], (isAuthenticated) ->
        unless isAuthenticated
            res.statusCode = 401
            res.setHeader "WWW-Authenticate", 'Basic realm="Secure Area"'
            res.end "Request unauthorized"
            next()

        appName = req.params.name
        appName = req.params.name.replace /\.git/, ""
        appRepo = "#{appsDir}/#{appName}"

        req.url = req.url.substring "/repo".length
        req.url = req.url.replace /\.git/, ""

        if req.method is "POST"
            repos.on 'push', (push) ->
                repos.exists appName, (exists) ->
                    configureNewRepo(appRepo) if not exists
                    push.accept()

        repos.handle req, res
