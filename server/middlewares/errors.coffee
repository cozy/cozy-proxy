localization = require '../lib/localization_manager'
logger = require('printit')
    date: true
    prefix: 'app:error'


module.exports = (err, req, res, next) ->

    if err instanceof Error
        logger.error err.message
        logger.error err.stack

    statusCode = err.status or 500
    message = if err instanceof Error then err.message else err.error
    message = message or 'Server error occurred' # default message

    if err.headers? and Object.keys(err.headers).length > 0 and !res.headersSent
        res.set header, value for header, value of err.headers

    content =
        error: message
        trans: localization.t message
    content.errors = err.errors if err.errors

    if res.headersSent
        res.end content
    else if err.template? and req?.accepts('html') is 'html'
        res.render err.template.name, err.template.params, (err, html) ->
            res.status(statusCode).send html
    else
        res.status(statusCode).send content
