Client = require("request-json").JsonClient


class PasswordKeys

    constructor: ->
        @client = new Client "http://localhost:9101/"
        @name = process.env.NAME
        @token = process.env.TOKEN
        if process.env.NODE_ENV in ["production", "test"]
            @client.setBasicAuth @name, @token

    initializeKeys: (pwd, callback) ->
        @client.post "accounts/password/", password: pwd, callback

    updateKeys: (pwd, callback) ->
        @client.put "accounts/password/", password: pwd, callback

    resetKeys: (pwd, callback) ->
        @client.put "accounts/password/", password: pwd, (err, res, body) =>
            if res?.statusCode is 400
                @client.del "accounts/reset/", callback
            else
                callback err


module.exports = new PasswordKeys()
