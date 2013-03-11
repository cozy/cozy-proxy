Client = require("request-json").JsonClient

client = new Client "http://localhost:9101/"


module.exports = class PasswordKeys


    initializeKeys: (pwd, callback) ->
        client.post "accounts/password/", password: pwd, (err, res, body) =>
            if err
                callback err
            else
                callback()

    updateKeys: (pwd, callback) ->
        client.put "accounts/password/", password: pwd, (err, res, body) =>
            if err
                callback err
            else
                callback()

    deleteKeys: (callback) ->
        client.del "accounts/", (err, res, body) =>
            if err
                callback err
            else
                callback()

    resetKeys: (callback) ->
        client.del "accounts/reset/", (err, res, body) =>
            if err
                callback err
            else
                callback()
