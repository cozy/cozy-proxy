

## Step 3/5 : Create a password

### URI

`:userID/password`


### Models

[&lt;UserModel&gt;] (https://github.com/cozy/cozy-proxy/blob/development/client/app/models/user.coffee)
```
<UserModel> user = {
    <id> id,
}
```

[&lt;StepModel&gt;] (https://github.com/cozy/cozy-proxy/blob/development/client/app/models/step.coffee)
```
    <string> slug: 'set_password',
    <step> value: 3/5,
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

    password
        label=t(step.field.label)
        value=step.field.value
        complexity=step.field.complexity

    step
        slug=step.name
        value=step.value

    button
        label='next'
        action= @doSubmit
```
