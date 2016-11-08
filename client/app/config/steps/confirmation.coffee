module.exports = {
    name: 'confirmation',
    route: 'register/confirmation',
    view : 'steps/confirmation'
    save: (data) ->
        onboardedSteps = [
            'welcome',
            'agreement',
            'password',
            'infos',
            'accounts',
            'confirmation'
        ]
        return fetch '/register',
            method: 'PUT',
            # Authentify
            credentials: 'include',
            body: JSON.stringify {onboardedSteps: onboardedSteps}
        .then @handleSaveSuccess, (err) =>
            throw new Error 'step accounts server error'
}
