## Step 4/5 : Password was validated

### URI

`:userID/validated`


### Models

[&lt;UserModel&gt;] (https://github.com/cozy/cozy-proxy/blob/development/client/app/models/user.coffee)
```
<UserModel> user = {
    <id> id,
}
```
[&lt;StepModel&gt;] (https://github.com/cozy/cozy-proxy/blob/development/client/app/models/step.coffee)
```
<StepModel> step = {
    <string> slug: 'validated',
    <step> value: 4/5,
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

div key='welcome-${user.id}-${step.name}'
    h1
        content='${user.name} ${step.name}'

    step
        slug=step.name
        value=step.value

    button
        label='browse'
        action=@doSubmit
```
