

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
    <boolean> disabled: false
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
}
</pre>
<pre>
URI = {
	<uri> CGU: 'cgu/',
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
div key='share-@state.userId'
	h1
		content=@state.userName

    input
        label=@state.fieldLabel
        value=@state.is_share
        type='checkbox'

	step
		slug=@state.stepSlug
		value=@state.stepValue

	button
		label='next'
		action=() -> @gotoNextStep()
```
