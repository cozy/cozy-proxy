module.exports = {
    name: 'agreement',
    route: 'register/agreement',
    view : 'steps/agreement',
    save: (data) ->
        onboardedSteps = [
            'welcome',
            'agreement'
        ]
        if data and data.allowStats
            allowStats = data.allowStats
        else
            allowStats = false
        return fetch '/register',
            method: 'POST',
            body: JSON.stringify
                onboardedSteps: onboardedSteps,
                isCGUaccepted: true,
                allow_stats: allowStats
        .then @handleSaveSuccess, @handleServerError
}
