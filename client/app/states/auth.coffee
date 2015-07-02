StateModel = require 'lib/state_model'


module.exports = class Auth extends StateModel

    initialize: ->
        @alert   = new Bacon.Bus()
        @recover = new Bacon.Bus()
        @isBusy  = new Bacon.Bus()

        @add 'alert', @alert.toProperty()
        @add 'recover', @recover.toProperty false
