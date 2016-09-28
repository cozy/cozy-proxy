
Questions :

I actually think about `React.propTypes`.
Can we define specific data types such as :
 - email (max length? is there any? etc.),
 - id: how may number, how many string char?
 - password,
 - step: number between 0 and 1,
 - etc.


## `StateComponent` API

<pre>
&lt;class&gt; StateComponent extends Backbone.BaseView

	initialize: (props) ->

		// Here is a Backbone listener
		// see how to do this with bacon stream listener
		// Bacon methods and observable could help :
		// `Bacon.fromEvent`, `observable.subscribe` etc.

		@listenTo(props.model, 'change', @render)


	// Dispatched after 1rst render
	onStart: ->
		// ...


	// Dispatched after all render
	onEnd: ->
		// ...


	// Dispatched after all error
	onError: ->
		// ...


	// Dispatched after hiding component
	onBackground: ->
		// ...


	// Dispatched before removing component
	onRemove: ->
		// ...


	// Return markdown that will be
	// add to the HTML document
	render: () ->
		return &lt;markup&gt;

</pre>

<pre>
&lt;class&gt; Component extends StateComponent

	// Inspired from `React.PropTypes`
	// Important to describe state
	// and to understand what is needed in one look

	&lt;object&gt; stateTypes: {
		'userID': `string.required`
		'userName': `string`
		'is_registered': `boolean`
	}


	&lt;object&gt; state


	// Listen to this model
	// to update component
	// throw `compenent.render()`

	&lt;model&gt; model : user


</pre>

## State API

### Getters
 - Called directly by `StateComponent`,
 - takes given `state` in arguments,
 - get information from `model` or `collection`,
 - should return the expected data.


# Scenaris


## Step 1/5 : Welcome!

### URI

`/welcome/:userID`

### data

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

### actions

<pre>
    gotoNextStep: ->
        hash = Getter.getNextStepURI(@state)
        @navigate hash, true

</pre>


### markup
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
