module.exports = {
    name: 'infos',
    route: 'register/infos',
    view : 'steps/infos',
    isActive: (user) ->
        return not user.hasValidInfos
    save: (data) ->
        data.onboardedSteps = [
            'welcome',
            'agreement',
            'password',
            'infos'
        ]
        return fetch '/register',
            method: 'PUT',
            # Authentify
            credentials: 'include',
            body: JSON.stringify data
        .then @handleSaveSuccess, @handleServerError
}
