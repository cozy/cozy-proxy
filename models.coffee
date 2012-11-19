Client = require("request-json").JsonClient

# Main class used to manage models.
# It requires to be extend and "typed". See examples below.
class DbManager

    constructor: ->
        @dbClient = new Client "http://localhost:9101/"

    all: (callback) ->
        @dbClient.post "request/#{@type}/all/", {}, (err, response, users) ->
            if err
                callback err
            else if response.statusCode != 200
                callback new Error(users)
            else
                callback null, users

    create: (model, callback) ->
        @dbClient.post "data/", model, (err, response, model) =>
             if err
                 callback err, 500
             else if response.statusCode != 201
                 callaback new Error("Error occured"), response.statusCode
             else
                 callback null, 201, model

    merge: (model, callback) ->
        @dbClient.put "data/merge/#{model._id}/", data, (err, res, body) =>
            if err
                callback err
            else if res.statusCode != 200
                callback new Error(users)
            else
                callback null

class exports.UserManager extends DbManager
   type: "user"

class exports.InstanceManager extends DbManager
   type: "cozyinstance"
