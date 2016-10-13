module.exports = {
    name: 'infos',
    route: 'infos',
    view : 'steps/infos',
    isActive: (user) ->
        return not user.hasInfos
}
