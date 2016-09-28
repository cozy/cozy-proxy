
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
