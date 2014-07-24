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
    'routes/reset': get: index.resetRoutes

    'register':
        get: auth.registerIndex
        post: [auth.register, utils.authenticate]

    'login': post: utils.authenticate
    'login/forgot': post: auth.forgotPassword
    'login*': get: auth.loginIndex
    'logout': get: [utils.isAuthenticated, auth.logout]

    'password/reset/:key':
        get: auth.resetPasswordIndex
        post: auth.resetPassword

    'authenticated': get: auth.authenticated
    'status': get: index.status

    'public/:name/*': all: apps.publicApp
    'public/:name*': all: apps.appWithSlash

    'disk-space': get: disk.getSpace

    'device*':
        post: devices.management
        delete: devices.management

    'apps/:name/*': all: [utils.isAuthenticated, apps.app]
    'apps/:name*': all: [utils.isAuthenticated, apps.appWithSlash]

    'cozy/*': all: devices.replication

    '.well-known/host-meta.?:ext': get: experiment.webfingerHostMeta
    '.well-known/:module': all: experiment.webfingerAccount

    '*': all: [
        utils.isAuthenticated
        index.defaultRedirect
    ]
