fs = require 'fs'
path = require 'path'

# if the app is running from build/ it uses JS, otherwise it uses jade
module.exports = ->
    ext = 'js'
    try
        fs.lstatSync path.resolve __dirname, "../views/login.#{ext}"
    catch e
        ext = 'jade'

    return ext
