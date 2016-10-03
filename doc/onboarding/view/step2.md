

## Step 2/5 : Share anonymously data

### URI

`:userID/share`


### Models

<pre>
user = {
	&lt;id&gt; id,
}
</pre>
<pre>
form = {
    &lt;boolean&gt; disabled: false
	&lt;array&gt; fields: [
		{
		    &lt;string&gt; label: 'Do you accept?',
		    &lt;string&gt; type: 'checkbox',
		    &lt;boolean&gt; value: false,
		}
	]
}
</pre>
<pre>
step = {
	&lt;string&gt; slug: 'share_data',
	&lt;step&gt; value: 2/5,
}
</pre>
<pre>
URI = {
	&lt;uri&gt; CGU: 'cgu/',
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
</pre>
