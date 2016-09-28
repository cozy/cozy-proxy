

## Step 2/5

### URI

`/login-/:userID`


### data

<pre>
user = {
	&lt;id&gt; id,
}
</pre>
<pre>
form = {
    &lt;string&gt; field_label: 'Do you accept?'
    &lt;boolean&gt; is_share: false
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


### actions

<pre>
    gotoNextStep: ->
        hash = Getter.getNextStepURI(@state)
        @navigate hash, true

</pre>


### markup
<pre>
div key='share-@state.userId'
	h1
		content=@state.userName

    input
        label=@state.fieldLabel
        value=@state.is_share

	step
		slug=@state.stepSlug
		value=@state.stepValue
        type='checkbox'

	button
		label='next'
		action=() -> @gotoNextStep()
</pre>
