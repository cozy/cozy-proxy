Backbone = require 'backbone'
$ = require 'jQuery'

# StepModel
# Backbone wrapper for Onboarding's Step models
# This Class is a proxy between Backone's logic and native Onboarding Steps
# as declared in lib/onboarding
module.exports = class StepModel extends Backbone.Model

    # Map needed property to current model
    # @param
    #  * step An onboarding Step object (see lib/onboarding)
    initialize: ({step, next}) ->
        @step = step

        # We map the defaults steps properties in the current model
        # There will be more properties/functions in the future.
        ['name', 'route', 'view', 'username'].forEach (property) =>
            @set property, step[property]

        @set 'next', next


    submit: (data) ->
        # TODO: should handle errors here
        if @step.validate? and (errors = @step.validate(data))
            return false

        @step.submit(data)
        return true
