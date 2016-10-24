module.exports = {
    name: 'welcome',
    route: 'register/welcome',
    view: 'steps/welcome',
    save: (data) ->
        return fetch '/register',
            method: 'POST',
            body: JSON.stringify {onboardedSteps: ['welcome']}
        .then @handleSaveSuccess, @handleSaveError
}
