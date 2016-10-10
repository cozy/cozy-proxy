module.exports = {
    name: 'preset', # named 'preset' to match existing codebase.
    route: 'welcome',
    view : './views/steps/welcome'
    props: {
        validate: (data) -> return data
    }
}
