
## Step 1/5 : Welcome!

### URI

`:userID/welcome`

### Models

<pre>
user = {
	&lt;string&gt; name,
	&lt;id&gt; id,
	&lt;email&gt; email,
	&lt;boolean&gt; is_registered: false
}
</pre>
<pre>
step = {
	&lt;string&gt; slug: 'welcome',
	&lt;step&gt; value: 1/5
}
</pre>

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
