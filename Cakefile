fs = require 'fs'

task 'jade', 'Transform jade file to CommonJS format', ->
    glob        = require 'glob'
    prependFile = require 'prepend-file'
    data = """var jade = require('jade/runtime');
              module.exports = """
    for file in glob.sync './build/server/views/**/*.js'
        prependFile.sync file, data

task 'locales', 'convert JSON lang files to JS', ->
    # server files
    for file in fs.readdirSync './server/locales/'
        filename = './server/locales/' + file
        template = fs.readFileSync filename, 'utf8'
        exported = "module.exports = #{template};\n"
        name     = file.replace '.json', '.js'
        fs.writeFileSync "./build/server/locales/#{name}", exported
