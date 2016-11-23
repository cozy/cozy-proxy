module.exports = {
    name: 'accounts',
    route: 'register/accounts',
    view: 'steps/accounts',

    isActive: (user) ->
        return 'konnectors' in user.apps

    save: (data) ->
        onboardedSteps = [
            'welcome',
            'agreement',
            'password',
            'infos',
            'accounts'
        ]
        return fetch '/register',
            method: 'PUT',
            # Authentify
            credentials: 'include',
            body: JSON.stringify {onboardedSteps: onboardedSteps}
        .then @handleSaveSuccess, @handleServerError
}
