## Step 4/5 : Password was validated

### URI

`:userID/validated`


### Models

<pre>
user = {
	&lt;id&gt; id,
}
</pre>
<pre>
step = {
	&lt;string&gt; slug: 'validated',
	&lt;step&gt; value: 4/5,
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
div key='password-@state.userId'
	h1
		content=@state.userName

	step
		slug=@state.stepSlug
		value=@state.stepValue

    # Shoul goto
	button
		label='browse'
		action=() -> @gotoNextStep()
</pre>
