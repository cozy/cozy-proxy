
## Step 1/5 : Welcome!

### URI

`:userID/welcome`

### Models

[&lt;UserModel&gt;] (https://github.com/cozy/cozy-proxy/blob/development/client/app/models/user.coffee)
```
<UserModel> user = {
    <string> name,
    <id> id,
    <email> email,
    <boolean> is_registered: false
}
```
[&lt;StepModel&gt;] (https://github.com/cozy/cozy-proxy/blob/development/client/app/models/step.coffee)
```
<StepModel> step = {
    <string> slug: 'welcome',
    <step> value: 1/5
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

    step
        slug=step.name
        value=step.value

    button
        label='next'
        action=@doSubmit
```
