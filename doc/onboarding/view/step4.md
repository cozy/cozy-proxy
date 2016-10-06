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


### Getters

```
    getNextStepURI: (state) ->
        // Route getter should "know" the relation
        // between screens
        // check state values
        // return <URI> URI
```


### Actions

```
    gotoNextStep: ->
        hash = Getter.getNextStepURI(@state)
        @navigate hash, true
```


### Markup
```
div key='password-@state.userId'
	h1
		content=@state.userName

	step
		slug=@state.stepSlug
		value=@state.stepValue

	button
		label='browse'
		action=() -> @gotoNextStep()
```
