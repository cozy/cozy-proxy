Client = require("request-json").JsonClient



module.exports = class PasswordKeys

    constructor: ->
        @client = new Client "http://localhost:9101/"
        @name = process.env.name
        @token = process.env.token
        if process.env.NODE_ENV is "production"
            @client.setBasicAuth @name, @token

    initializeKeys: (pwd, callback) ->
        @client.post "accounts/password/", password: pwd, (err, res, body) =>
            if err
                callback err
            else
                callback()

    updateKeys: (pwd, callback) ->
        if process.env.NODE_ENV is "production"
            @client.setBasicAuth @name, @token
        @client.put "accounts/password/", password: pwd, (err, res, body) =>
            if err
                callback err
            else
                callback()

    deleteKeys: (callback) ->
        if process.env.NODE_ENV is "production"
            @client.setBasicAuth @name, @token
        @client.del "accounts/", (err, res, body) =>
            if err
                callback err
            else
                callback()

    resetKeys: (callback) ->
        if process.env.NODE_ENV is "production"
            @client.setBasicAuth @name, @token
        @client.del "accounts/reset/", (err, res, body) =>
            if err
                callback err
            else
                callback()
