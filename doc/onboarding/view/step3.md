

## Step 3/5 : Create a password

### URI

`:userID/password`


### Models

<pre>
user = {
	&lt;id&gt; id,
}
</pre>
<pre>
form = {
	&lt;boolean&gt; disabled: true
	fields: [
		{
		    &lt;slug&gt; name: 'password',
		    &lt;string&gt; label: 'Password'
		    &lt;string&gt; type: 'password'
		    &lt;password&gt; value
		}
	]
}
</pre>
<pre>
step = {
	&lt;string&gt; slug: 'set_password',
	&lt;step&gt; value: 3/5,
}
</pre>


### Getters

<pre>
    getPasswordComplexity: (value) ->
        // Apply algorithm to know
        // if password value is secured enough
        // Add a value >= 0 and =< 1
        // return { complexity, value }
		// ie. { key='weak', value: 0.2 }


    getNextStepURI: (state) ->
        // Route getter should "know" the relation
        // between screens
        // check state values
        // return <URI> URI
</pre>


### Actions

<pre>
    getFormData: ->
        return { password: @state.password, id: @state.userID }


    validate: ->
        { password } = @getFormData()

        // Should return an object
        // ie. label='weak', value=0.2
        complexity = Getter.getPasswordComplexity(password)        

        // Form cant be submitted while
        // password is not secured enought
        validate = complexity.label is 'strong'

        // Update view with:
		// 1. password complexity infos,
		// 2. save password tmp value,
		// 3. define `disabled` value.
        // to display update PasswordComplexityComponent
        @setState {complexity, disabled: !validate, password }

        return validate


    onSuccess: ->
        hash = Getter.getNextStepURI(@state)
        @navigate hash, true
</pre>


### Markup
<pre>
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
		action=@send
</pre>
