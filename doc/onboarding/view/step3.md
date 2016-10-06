

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
```
form = {
	<boolean> disabled: true
	fields: [
		{
		    <slug> name: 'password',
		    <string> label: 'Password'
		    <string> type: 'password'
		    <password> value
		}
	]
}
```
[&lt;StepModel&gt;] (https://github.com/cozy/cozy-proxy/blob/development/client/app/models/step.coffee)
```
	<string> slug: 'set_password',
	<step> value: 3/5,
}
```


### Getters

```
    getPasswordComplexity: (value) ->
        // Apply algorithm to know
        // if password value is secured enough
        // Add a value >= 0 and =< 1
        // return { complexity, value }
		// ie. { key='weak', value: 0.2 }


    getNextStepURI: (state) ->
        // Route getter should "know" the relation
        // between screens
        // check state values
        // return <URI> URI
```


### Actions

```
    getFormData: ->
        return { password: @state.password, id: @state.userID }


    validate: ->
        { password } = @getFormData()

        // Should return an object
        // ie. label='weak', value=0.2
        complexity = Getter.getPasswordComplexity(password)        

        // Update view with:
		// 1. password complexity infos,
		// 2. save password tmp value,
        // to update PasswordComplexityComponent
        @setState {complexity, password }

        return true


    onSuccess: ->
        hash = Getter.getNextStepURI(@state)
        @navigate hash, true
```


### Markup
```
div key='password-@state.userId'
	h1
		content=@state.userName

    password
        label=t('passwordLabel')
        value=@state.password
		complexity=@state.complexity

	step
		slug=@state.stepSlug
		value=@state.stepValue

	button
		label='next'
        disabled=@state.disabled
		action=@send
```
