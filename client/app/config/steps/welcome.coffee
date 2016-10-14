handleSaveSuccess = () ->
    console.debug 'success'

handleSaveError = () ->
    throw new Error 'Error occured during save'

module.exports = {
    name: 'preset', # named 'preset' to match existing codebase.
    route: 'welcome',
    view: 'steps/welcome',
    save: (data) ->
        return fetch '/register',
            method: 'POST',
            body: JSON.stringify {onboardedSteps: ['welcome']}
        .then @handleSaveSuccess, @handleSaveError
}
