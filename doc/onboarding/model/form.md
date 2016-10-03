# `form` State

## Definition
State of a form that includes its values but also :
 - required field or
 - ability to submit or not all the form.

```
{
    <boolean> disabled: false
	<array> fields: [
		{
		    <string> label: 'Do you accept?',
		    <string> type: 'checkbox',
		    <boolean> value: false,
		},
        # ...
	]
}
```

## API

### `errors`
Array that contain all errors by its slug name.


### `disabled`
The form can't be submitted if it's containing errors.
