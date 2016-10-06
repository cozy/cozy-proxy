

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
`Getters` are methods implemented here into `StateModel` to get global state.
All views get data from this `State`.

```
	getFormData: ->
		password = @get('password')
		return {
			complexity: getPasswordComplexity(password),
			password,
			id: @get('userID'),
		}

    getPasswordComplexity: (value) ->
        // Apply algorithm to know
        // if password value is secured enough
        // Add a value >= 0 and =< 1
        // return { complexity, value }
		return { key='weak', value: 0.2 }


    getNextStepURI: (state) ->
        // Route getter should "know" the relation
        // between screens
        // check state values
        // return <URI> URI
```


### Actions
Actions are handled by `StateMachineController`.
It is here a single `BackboneView` that will listen to `StateMachineModel` changes et events triggered by ``BackboneView`.

```
	initialize: ->
		// Event triggered from View
		@on 'submit:form', @doSubmit

		// Update views from State
		StateMachineModel.on 'change, @render


	doSubmit: (data) ->
		// Save ComponentData into State
		// then State will change
		// then Controller will render all app
		return StateMachineModel.save()


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
		action= () -> StateMachineController.trigger 'form:submit'
```
