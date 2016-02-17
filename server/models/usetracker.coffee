cozydb = require 'cozydb'

module.exports = UseTracker = cozydb.getModel 'UseTracker',
    app: String
    dateStart: Date
    dateEnd: Date
    duration: Number
