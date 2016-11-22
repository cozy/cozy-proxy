module.exports = {
    name: 'agreement',
    route: 'register/agreement',
    view : 'steps/agreement',
    save: (data) ->
        onboardedSteps = [
            'welcome',
            'agreement'
        ]
        return fetch '/register',
            method: 'POST',
            body: JSON.stringify
                onboardedSteps: onboardedSteps,
                isCGUaccepted: true,
                allow_stats: data.allowStats
        .then @handleSaveSuccess, @handleServerError
}
