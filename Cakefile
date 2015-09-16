{exec} = require 'child_process'
fs     = require 'fs'
logger = require('printit')
    date: false
    prefix: 'cake'

option '-f', '--file [FILE*]' , 'List of test files to run'
option '-d', '--dir [DIR*]' , 'Directory of test files to run'
option '-e' , '--env [ENV]', 'Run tests with NODE_ENV=ENV. Default is test'
option '' , '--use-js', 'If enabled, tests will run with the built files'

options =  # defaults, will be overwritten by command line options
    file        : no
    dir         : no

# Grab test files of a directory recursively
walk = (dir, excludeElements = []) ->
    fileList = []
    list = fs.readdirSync dir
    if list
        for file in list
            if file and file not in excludeElements
                filename = "#{dir}/#{file}"
                stat = fs.statSync filename
                if stat and stat.isDirectory()
                    fileList2 = walk filename, excludeElements
                    fileList = fileList.concat fileList2
                else if filename.substr(-6) is "coffee"
                    fileList.push filename
    return fileList

taskDetails = '(default: ./tests, use -f or -d to specify files and directory)'
task 'tests', "Run tests #{taskDetails}", (opts) ->
    logger.options.prefix = 'cake:tests'
    files = []
    options = opts

    if options.dir
        dirList   = options.dir
        files = walk(dir, files) for dir in dirList
    if options.file
        files  = files.concat options.file
    unless options.dir or options.file
        files = walk "test"


    env = if options['env'] then "NODE_ENV=#{options.env}" else "NODE_ENV=test"
    env += " USE_JS=true" if options['use-js']? and options['use-js']
    env += " PORT=4444"
    logger.info "Running tests with #{env}..."
    command = "#{env} mocha " + files.join(" ") + " --reporter spec --colors "
    command += "--compilers coffee:coffee-script/register"
    exec command, (err, stdout, stderr) ->
        console.log stdout
        console.log stderr
        if err
            err = err
            logger.error "Running mocha caught exception:\n" + err
            process.exit 1
        else
            logger.info "Tests succeeded!"
            process.exit 0

task "coverage", "Generate code coverage of tests", ->
    logger.options.prefix = 'cake:coverage'
    files = walk "test"

    logger.info "Generating instrumented files..."
    bin = "./node_modules/.bin/coffeeCoverage --path abbr"
    command = "mkdir instrumented && " + \
              "#{bin} server.coffee instrumented/server.js && " + \
              "#{bin} server instrumented/server && " + \
              "cp -R client instrumented/"
    exec command, (err, stdout, stderr) ->
        if err
            logger.error err
            cleanCoverage -> process.exit 1
        else
            logger.info "Instrumented files generated."
            env = "COVERAGE=true PORT=4444 NODE_ENV=test"
            command = "#{env} mocha test/ " + \
                      "--compilers coffee:coffee-script/register " + \
                      "--reporter html-cov > coverage/coverage.html"
            logger.info "Generating code coverage..."
            exec command, (err, stdout, stderr) ->
                if err
                    logger.error err
                    cleanCoverage -> process.exit 1
                else
                    cleanCoverage ->
                        logger.info "Code coverage generation succeeded!"
                        process.exit 0

# use exec-sync npm module and use "invoke" in other tasks
cleanCoverage = (callback) ->
    logger.info "Cleaning..."
    command = "rm -rf instrumented"
    exec command, (err, stdout, stderr) ->
        if err
            logger.error err
            callback err
        else
            logger.info "Cleaned!"
            callback()

task "clean-coverage", "Clean the files generated for coverage report", ->
    cleanCoverage (err) ->
        if err
            process.exit 1
        else
            process.exit 0


task "lint", "Run Coffeelint", ->
    process.env.TZ = "Europe/Paris"
    command = "coffeelint "
    command += " -f coffeelint.json -r server/"
    logger.options.prefix = 'cake:lint'
    logger.info 'Start linting...'
    exec command, (err, stdout, stderr) ->
        if err
            logger.error err
        else
            console.log stdout


commonJSJade = ->
    glob        = require 'glob'
    prependFile = require 'prepend-file'

    data = """var jade = require('jade/runtime');
              module.exports = """
    for file in glob.sync './build/server/views/**/*.js'
        prependFile.sync file, data

# convert JSON lang files to JS
buildJsInLocales = ->
    path = require 'path'
    for file in fs.readdirSync './client/app/locales/'
        filename = './client/app/locales/' + file
        template = fs.readFileSync filename, 'utf8'
        exported = "module.exports = #{template};\n"
        name     = file.replace '.json', '.js'
        fs.writeFileSync "./build/client/app/locales/#{name}", exported
        # add locales at the end of app.js
    exec "rm -rf build/client/app/locales/*.json"

task 'build', 'Build CoffeeScript to Javascript', ->
    logger.options.prefix = 'cake:build'
    logger.info "Start compilation..."
    command = """
                rm -rf build &&
                coffee -cb --output build/server server &&
                coffee -cb --output build/ server.coffee
                ./node_modules/.bin/jade -cPDH -o build/server/views server/views &&
                cd client &&
                ./node_modules/.bin/bower install &&
                brunch build --production && 
                mkdir -p build/client/app/locales/ &&
                rm -rf build/client/app/locales/* &&
                cp -R client/public build/client/ &&
                rm -rf client/app/locales/*.coffee"
              """
    exec command, (err, stdout, stderr) ->
        if err
            logger.error "An error has occurred while compiling:\n" + err
            process.exit 1
        else
            buildJsInLocales()
            commonJSJade()
            logger.info "Compilation succeeded."
            process.exit 0


task 'check-build', 'Check if the compiled files are up to date', ->
    logger.options.prefix = 'cake:check-build'
    jsDate = fs.statSync('build/server.js').mtime

    coffeeFiles = walk './server'
    coffeeFiles.push './server.coffee'

    coffeeDate = null
    for file in coffeeFiles
        fileDate = fs.statSync(file).mtime
        coffeeDate = fileDate if  fileDate > coffeeDate or coffeeDate is null

    if coffeeDate > jsDate
        msg = "Javascript build doesn't seem to be up to date. Are you " + \
              "sure you've built the sources? If, not please run 'cake build'."
        logger.warn msg
        process.exit 1
    else
        logger.info "Javascript build is up to date."
        process.exit 0
