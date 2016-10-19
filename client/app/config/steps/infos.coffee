module.exports = {
    name: 'infos',
    route: 'register/infos',
    view : 'steps/infos',
    isActive: (user) ->
        return not user.hasValidInfos
}
