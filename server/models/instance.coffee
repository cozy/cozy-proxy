cozydb = require 'cozydb'

module.exports = CozyInstance = cozydb.getModel 'CozyInstance',
    id:     type: String
    domain: type: String
    locale: type: String

CozyInstance.first = (callback) ->
    CozyInstance.request 'all', (err, instances) ->
        if err then callback err
        else if not instances or instances.length is 0 then callback null, null
        else  callback null, instances[0]

CozyInstance.getLocale = (callback) ->
    CozyInstance.first (err, instance) ->
        callback err, instance?.locale or null

CozyInstance.createOrUpdate = (instanceData, callback) ->
    CozyInstance.first (err, instance) ->
        if err? then callback err
        else if instance?
            instance.updateAttributes instanceData, callback
        else
            CozyInstance.create instanceData, callback


resetKey = null
CozyInstance.getResetKey = -> return resetKey

CozyInstance.setResetKey = (key) ->
    resetKey = key

    # the key has a 1h TTL
    setTimeout ->
        resetKey = null
    , 1 * 60 * 60 * 1000
