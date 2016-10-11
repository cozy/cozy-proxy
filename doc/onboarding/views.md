## Models
How to call these data into views?
```
user = OnboardingLib.getUser()
step = OnboardingLib.getState()
```


## Actions

```
    doSubmit: ->
        OnboardingLib.doSubmit()
```

## Markup


### Step 1/5 `:userID/welcome`

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


### Step 2/5 : Share data agreement as anonymous `:userID/share`
```
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

### Step 3/5 : Create a password `:userID/password`
```
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

### Step 4/5 : Password was validated `:userID/validated`
```
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
