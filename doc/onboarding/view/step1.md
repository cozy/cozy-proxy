
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

### Getters

<pre>
    getNextStepURI: (state) ->
        // Route getter should "know" the relation
        // between screens
        // check state values
        // return <URI> URI
</pre>


### Actions

<pre>
    gotoNextStep: ->
        hash = Getter.getNextStepURI(@state)
        @navigate hash, true

</pre>


### Markup
<pre>
div key='welcome-@state.userId'
	h1
		content=@state.userName

	step
		slug=@state.stepSlug
		value=@state.stepValue

	button
		label='next'
		action=() -> @gotoNextStep()
</pre>
