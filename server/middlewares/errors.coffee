logger = require('printit')
    date: true
    prefix: 'app:error'

module.exports = (err, req, res, next) ->

    statusCode = err.status or 500
    message = if err instanceof Error then err.message else err.error
    message = message or 'Server error occurred' # default message

    if err.headers? and Object.keys(err.headers).length > 0
        res.set header, value for header, value of err.headers

    if err.template?
        res.render "#{err.template.name}.jade", err.template.params
    else
        res.send statusCode, error: message

    if err instanceof Error
        logger.error err.message
        logger.error err.stack
