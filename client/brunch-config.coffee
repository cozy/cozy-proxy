exports.config =
    files:
        javascripts:
            joinTo:
                'scripts/vendor.js': /^(bower_components|vendor)/
                'scripts/app.js': /^app/
            order:
                before: [
                    'bower_components/jquery/dist/jquery.js'
                    'bower_components/bacon/dist/Bacon.js'
                ]

        stylesheets:
            joinTo: 'styles/app.css'

        templates:
            defaultExtension: 'jade'
            joinTo: 'scripts/app.js'

    plugins:
        jade:
            globals: ['t']
