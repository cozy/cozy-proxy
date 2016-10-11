

## Step 2/5 : Share anonymously data

### URI

`:userID/share`


### Models

[&lt;UserModel&gt;] (https://github.com/cozy/cozy-proxy/blob/development/client/app/models/user.coffee)
```
<UserModel> user = {
    <id> id,
}
```
```
form = {
    <array> fields: [
        {
            <slug> name: 'share',
            <string> label: 'Do you accept?',
            <string> type: 'checkbox',
            <boolean> value: false,
        }
    ]
}
```
[&lt;StepModel&gt;] (https://github.com/cozy/cozy-proxy/blob/development/client/app/models/step.coffee)
```
<StepModel> step = {
    <string> slug: 'share_data',
    <step> value: 2/5,
    <uri> cguURI: 'cgu/'
}
```


### Actions

```
    doSubmit: ->
        OnboardingLib.doSubmit()
```


### Markup
```
user = OnboardingLib.getUser()
step = OnboardingLib.getState()

div key='welcome-${user.id}-${step.name.id}'
    h1
        content='${user.name} ${step.name}'

    input
        label=step.field.label
        value=step.field.value
        type='checkbox'

    step
        slug=step.name
        value=step.value

    button
        label='next'
        action=@doSubmit
```
