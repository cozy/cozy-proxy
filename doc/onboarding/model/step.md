# `step` State

## Definition
Locate onboarding progression

ie.
````
step = {
	<string> slug: 'welcome',
	<step> value: 1/5,
}
````


## API

### `value`

It's a value between 0 and 1.
The maximum value can change depending on the onboarding context: sometimes there are 4 steps, sometimes 5.

!!! TODO: functional use case should be defined here
