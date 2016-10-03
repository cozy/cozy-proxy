Backbone = require 'backbone'

# StepModel
# Backbone wrapper for Onboarding's Step models
# This Class is a proxy between Backone's logic and native Onboarding Steps
module.exports = class StepModel extends Backbone.Model

    # Map needed property to current model
    initialize: ({step}) ->
        @step = step

        ['name', 'route', 'view'].forEach (property) =>
            @set property, step[property]

    # Encapsulate call to step.submit
    submit: () ->
        @step.submit()
