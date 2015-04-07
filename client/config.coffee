exports.config =

    plugins:
        uglify:
            mangle: false
            compress:
                global_defs:
                    DEBUG: true
        cleancss:
            keepSpecialComments: false
            removeEmpty: true

    files:
        javascripts:
            joinTo:
                'scripts/app.js': /^app|^vendor/
            order:
                before: [
                    'vendor/scripts/jquery-1.11.0.js'
                    'vendor/scripts/spin.min.js'
                    'vendor/scripts/jquery-spinner.js'
                    'vendor/scripts/polyglot.min.js'
                ]
                after: [
                    'app/login.coffee'
                    'app/register.coffee'
                    'app/reset.coffee'
                ]

        stylesheets:
            joinTo: 'styles/app.css': /^app/

        templates:
            defaultExtension: 'jade'
            joinTo: 'scripts/app.js'

