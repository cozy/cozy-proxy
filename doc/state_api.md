# State

## Definition
This is an adaptation of state machine pattern : https://en.wikipedia.org/wiki/Finite-state_machine.

Choices have been taken for a small application.
Enhancement should be done in the future to handle more complex cases.

Here is the implementation context:
 - was though as an agnostic one,
 - but will be used with Backbone that
 - prevent using Immutability pattern..


### Adding specific `data.types` (see for later)
In the aim to remove data logic from views to models.
To have relevant form types used every where into the application.

I actually think about `React.propTypes`.
Can we define specific data types such as :
 - email (max length? is there any? etc.),
 - id: how may number, how many string char?
 - password,
 - step: number between 0 and 1,
 - etc.

 Maybe adding this stuff into https://github.com/cozy/cozy-ui

### Immutability (see for later)
Avoiding mutation with `Backbonejs` is an anti-pattern because this framework is based on mutation (collection, models, views).

We have decided to avoid this part for the the moment; see next time.

## API

```
    class state extend collection

        //...


        // Should test if all required fields
        // have a correct value (see @stateTypes)
        // If not return false
        // otherwhise return data
        validate: (data) ->
            formValuesAreOK = ->
                // ...

            unless (areValuesOK())
                return false
            else
                return data

```



## Getters
They are called directly from `ViewComponent` to get data from the global `state`.
 - takes given `state` in arguments,
 - get information from `model` (ie. `user`, `form`),
 - should return the expected data.
