module.exports = class RegisterPresetView extends Backbone.Model

    _steps: [
        'preset',
        'import',
        'email',
        'setup',
        'welcome'
    ]


    sync: -> return false


    toJSON: ->
        res = super()
        currentStep = @_steps.indexOf @get 'step'
        res.nextStep = @_steps[currentStep + 1]
        return res
