Client = require("request-json").JsonClient



module.exports = class PasswordKeys

    constructor: ->
        @client = new Client "http://localhost:9101/"
        @name = process.env.NAME
        @token = process.env.TOKEN
        if process.env.NODE_ENV is "production" or process.env.NODE_ENV is "test"
            @client.setBasicAuth @name, @token

    initializeKeys: (pwd, callback) ->
        @client.post "accounts/password/", password: pwd, (err, res, body) =>
            if err
                callback err
            else
                callback()

    updateKeys: (pwd, callback) ->
        @client.put "accounts/password/", password: pwd, (err, res, body) =>
            if err
                callback err
            else
                callback()

    resetKeys: (callback) ->
        @client.del "accounts/reset/", (err, res, body) =>
            if err
                callback err
            else
                callback()
