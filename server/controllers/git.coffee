fs = require 'fs-extra'
async = require 'async'
pushover = require 'pushover'
gitEmit = require 'git-emit'
mkdirp = require 'mkdirp'
exec = require('child_process').exec

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

            # Add Git hook listener
            gitEmit("#{appRepo}/.git").on('update', updateRepo)

    
# Add Git hook listeners for each app that already exists
fs.readdir appsDir, (err, apps) ->
    for app in apps
        if fs.existsSync "#{appsDir}/#{app}/.git"
            gitEmit("#{appsDir}/#{app}/.git").on('update', updateRepo)
            exec "git config receive.denyCurrentBranch ignore"
            , cwd: "#{appsDir}/#{app}"



# Module function
module.exports.serveRepo = (req, res, next) ->
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
