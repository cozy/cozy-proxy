fs = require 'fs-extra'
async = require 'async'
pushover = require 'pushover'
gitEmit = require 'git-emit'
mkdirp = require 'mkdirp'
exec = require('child_process').exec
logger = require('printit')
            date: false
            prefix: 'git:server'

appsDir = '/usr/local/cozy/apps'

# Handle HTTP requests to Git repositories via pushover
repos = pushover appsDir,
    autocreate: false
    checkout: true

# Initialize an array of stream for each repository
resStreams = {}


# Action that will be triggered on the 'update' Git hook
updateRepo = (appName, callback) ->
    appRepo = "#{appsDir}/#{appName}"
    exec "git reset --hard", cwd: appRepo, (err, stdout, stderr) ->
        callback err


# Add a listener for an application that will trigger on 'update' hook
# Client is waiting for an answer at this point, so we need to call
# `update.accept()` at the end
addGitListener = (appName) ->
    appRepo = "#{appsDir}/#{appName}"
    logger.info "Adding Git hook listener for #{appRepo}"
    listener = gitEmit("#{appRepo}/.git")
    listener.on 'post-update', (update) ->
        updateRepo appName, (err) ->
            if err
                logger.error err
                update.reject()
            else
                update.accept()


# Repo has already been created by pushover at this point.
# We just need to configure it so that client won't receive an undesired error
# Also, we need to remove ".git" from repository's path
configureNewRepo = (appName, callback) ->
    appRepo = "#{appsDir}/#{appName}"
    exec "git config receive.denyCurrentBranch ignore"
    , cwd: "#{appRepo}.git", ->
        fs.move "#{appRepo}.git", appRepo, (err) ->
            return callback err if err
            addGitListener appName
            updateRepo appName, callback


# Add Git hook listeners for each app that already exists
fs.readdir appsDir, (err, apps) ->
    for appName in apps
        appRepo = "#{appsDir}/#{appName}"
        if fs.existsSync "#{appRepo}/.git"
            addGitListener appName
            exec "git config receive.denyCurrentBranch ignore"
            , cwd: "#{appsDir}/#{appName}"


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

    appName = req.params.name
    appName = req.params.name.replace /\.git/, ""

    # Check that the repository's name is not too long or too exotic
    unless appName.match /^[a-zA-Z0-9-]{2,30}$/
        res.statusCode = 400
        return res.end "Bad request"

    appRepo = "#{appsDir}/#{appName}"

    req.url = req.url.substring "/repo".length
    req.url = req.url.replace /\.git/, ""

    if req.method is "POST"
        repos.on 'push', (push) ->
            repos.exists appName, (exists) ->
                if not exists
                    configureNewRepo appName, (err) ->
                        if err
                            push.reject()
                            next err
                        else
                            push.accept()
                else
                    push.accept()

    repos.handle req, res
