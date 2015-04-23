fs = require 'fs'
gitBackend = require 'git-http-backend'
exec = require('child_process').exec
spawn = require('child_process').spawn
logger = require('printit')
            date: false
            prefix: 'git:server'

appsDir = '/usr/local/cozy/apps'


# Add a listener for an application that will trigger on 'update' hook
# Client is waiting for an answer at this point, so we need to call
# `update.accept()` at the end
addGitHook = (appName, callback) ->
    appRepo = "#{appsDir}/#{appName}"
    logger.info "Adding Git `post-update` hook for #{appName}"

    fs.writeFile "#{appRepo}/.git/hooks/post-update"
    , """
      #!/bin/sh
      export GIT_DIR=#{appRepo}/.git/
      export GIT_WORK_TREE=#{appRepo}/
      git reset --hard > /dev/null
      #exec cozy-monitor deploy #{appName}
      """
    , (err) -> callback err


# Create a directory, initialize a Git repository in it, then configure it to
# be able to receive pushes even as a "non-bare" repository.
configureNewRepo = (appName, callback) ->
    appRepo = "#{appsDir}/#{appName}"

    exec "git init -q #{appRepo}", (err) ->
        return callback err if err

        exec "git config receive.denyCurrentBranch ignore"
        , cwd: appRepo , (err) ->
            return callback err if err
            addGitHook appName, callback


# Add Git hook listeners for each app that already exists at proxy startup
fs.readdir appsDir, (err, apps) ->
    logger.error err if err

    for appName in apps
        appRepo = "#{appsDir}/#{appName}"
        if fs.existsSync "#{appRepo}/.git"

            exec "git config receive.denyCurrentBranch ignore"
            , cwd: appRepo, (err) ->
                logger.error err if err

            addGitHook appName, (err) ->
                logger.error err if err


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

    backend = gitBackend req.url, (err, service) ->
        return res.end "#{err}\n" if err

        executeGitAction = ->
            res.setHeader 'content-type', service.type

            ps = spawn service.cmd, service.args.concat(appRepo)
            ps.stdout.pipe(service.createStream()).pipe(ps.stdin)

        if service.cmd is "git-receive-pack" \
        and not fs.existsSync appRepo
            configureNewRepo appName, (err) ->
                return res.end "#{err}\n" if err
                executeGitAction()
        else
            executeGitAction()

    req.pipe(backend).pipe(res)
