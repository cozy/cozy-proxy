Backbone = require 'backbone'

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
        for property, value of @step.getData()
            @set property, value

        @set 'name', @step.getName()
        @set 'error', @step.getError()

        @set 'next', next


    submit: (data={}) ->
        return @step.submit(data)


    validate: (data={}) ->
        return @step.validate(data)
