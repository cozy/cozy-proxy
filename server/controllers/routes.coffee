index = require './index'
auth = require './authentication'
devices = require './devices'
disk = require './disk'
apps = require './applications'
experiment = require './experimental'

utils = require '../middlewares/authentication'

passport = require 'passport'

module.exports =

    'routes': get: index.showRoutes
    'routes/reset*': get: index.resetRoutes

    'register':
        get: auth.registerIndex
        post: [auth.register, utils.authenticate]

    'login':
        get: auth.loginIndex
        post: utils.authenticate
    'login/forgot': post: auth.forgotPassword
    'logout': get: [utils.isAuthenticated, auth.logout]

    'password/reset/:key':
        get: auth.resetPasswordIndex
        post: auth.resetPassword

    'authenticated': get: auth.authenticated
    'status': get: index.status

    'public/:name/*': all: apps.publicApp
    'public/:name*': all: apps.appWithSlash

    'disk-space': get: disk.getSpace

    'device':
        post: devices.create
    'device/:login':
        put: devices.update
        delete: devices.remove

    'apps/:name/': all: [utils.isAuthenticated, apps.app]
    
    'apps/:name*': all:[utils.isAuthenticated, apps.app]

    # 'apps/:name*': all: [utils.isAuthenticated, apps.appWithSlash]

    'replication/*': all: devices.replication
    'ds-api/*': all: devices.dsApi
    'versions': get: devices.getVersions
    # Temporary - 01/05/14
    'cozy/*': all: devices.oldReplication

    '.well-known/host-meta.?:ext': get: experiment.webfingerHostMeta
    '.well-known/:module': all: experiment.webfingerAccount

    '*': all: [
        utils.isAuthenticated
        index.defaultRedirect
    ]
