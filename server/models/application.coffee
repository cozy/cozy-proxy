americano = require 'americano-cozy'

module.exports = Application = americano.getModel 'Application',
    name: String
    displayName: String
    description: String
    slug: String
    state: String
    isStoppable: {type: Boolean, default: true}
    date: {type: Date, default: Date.now}
    icon: String
    iconPath: String
    iconType: String
    color: {type: String, default: null}
    git: String
    errormsg: String
    branch: String
    port: Number
    permissions: Object
    password: String
    homeposition: Object
    widget: String
    version: String
    domain: String #subdomain pointing to a cozy app
    needsUpdate: {type: Boolean, default: false}
    _attachments: Object

Application.domainSlug = (domain, callback) ->
    Application.request "all", {}, (err, res) ->
        return callback err if err?
        for app in res
            if app.domain is domain
                callback(null, app.slug)
                return
        callback null, ""
