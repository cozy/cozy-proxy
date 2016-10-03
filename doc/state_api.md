# State

## Definition
1. State defines the status of the application for one given time,
2. State value should be reflected to URI to keep consistency,
3. more?

See theory there: https://en.wikipedia.org/wiki/Finite-state_machine.

### Questions

#### Adding specific `data.types` ?
In the aim to remove data logic from views to models.
To have relevant form types used every where into the application.

I actually think about `React.propTypes`.
Can we define specific data types such as :
 - email (max length? is there any? etc.),
 - id: how may number, how many string char?
 - password,
 - step: number between 0 and 1,
 - etc.

#### Immutability?
How to avoid mutation? (no functional programing without avoiding mutation).


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
