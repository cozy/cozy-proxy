# Register process migration to Cozy v3
=======================================

Document based on https://github.com/cozy/cozy-stack/blob/master/docs/onboarding.md

## Property and variable names
  * All occurrences of `user` need to be renamed to `instance`, as we are now directly dealing with a Cozy instance.
  * All occurrences of `password` need to be renamed to `passphrase`.
  * `instance` properties are not named like actual `user` properties
    * `public_name` becomes `public-name`
    * `timezone` becomes `tz`
    * `email` becomes `owner-email`

## Handle registerToken
Presence of a `registerToken` means that the user access to her Cozy for the first time.

If started with a `registerToken`, the onboarding allows the user to create a passPhrase.

It's more or less the current behavior.

## Refactoring
We may take the opportunity to refactor Onboarding initalization in `application.coffee`, and change this part
```coffeescript
onboarding = new Onboarding(user, steps, ENV.onboardedSteps)
onboarding.onStepChanged (step) => @handleStepChanged(step)
onboarding.onStepFailed (step, err) => @handleStepFailed(step, err)
onboarding.onDone () => @handleTriggerDone()
```
to something like
```coffeescript
onboarding = new Onboarding
                        registerToken: registerToken
                        contextToken: contextToken
                        instance: instance
                        steps: steps
                        onStepChanged: (step) =>
                            @handleStepChanged(step)
                        onStepFailed: (step, err) =>
                            @handleStepFailed(step, err)
                        onDone: () =>
                            @handleTriggerDone()
```
The initial onboardedSteps are disappearing to be fetched later in the process.

## Dealing without saving first steps
With Cozy v3, we cannot save the step progression anymore, at least for the steps before the passphrase step. So both `welcome` and `agreement` steps should not have a `save` method anymore (So if the user leaves the onboarding before completing the `password` step, she will have to start from `welcome` step the next time she will access her Cozy).

The first three steps will be saved with the passphrase, in the current `password` step. We have to ensure that Cozy v3 is ready to handle an `onboardedSteps` property. We may also now ignore saving the first two steps in the `onboardedSteps` property.

We may save the next steps as we are currently doing.

## Saving steps
  * In `client/app/config/steps/password.coffee`, change the endpoint to `/auth/passphrase`, use http method `PUT`
  * In other steps `infos`, `accounts`, and `confirmation` use the endpoint `/instance` with method `POST`

## Retrieving instance data
In `infos` step : use the endpoint `/instance` with `GET` method to fetch instance data. Some property names will change.

## Display the total number of steps
In the current onboarding, we are using a property `hasValidInfos` to determine how many steps the onboarding will have. This property is computed and transmitted by the server. We cannot compute it client side without having access to `public-name` and `owner-email`, which should imply a serious security flaw.

Not having this property transmitted by the server will force us to display an estimated number of steps, or display this number only after the `password` step. This point needs to be clarified with both Backend Team and Product Team.

Maybe be the `hasValidInfos` property could be encrypted in the `registerToken` ?

## Handle contextToken
Presence of `contextToken` means that the user is already authentified. In this case, the onboarding should fetch instance data by performing a `GET` on the endpoint `/instance`. Once data is fetched, especially the `onboardedSteps` property, the onboarding determines the uncompleted steps or redirect the user to her home, as it currently does.

## Handle missing tokens
If none of `registerToken` or `contextToken` are passed to the onboarding, we have to throw an error and display a dedicated error page. This is some new stuff which has to be designed.
This behavior allows us to ignore the case when the user access her Cozy without `registerToken`, as we are not able to detect if a passphrase exists on the Cozy instance.
