

# How to add a `new step`?


### 1. Update workflow

Add your step name [here](https://github.com/cozy/cozy-proxy/blob/6e92cde0d5f382008098f8ddf993628c1b202f5d/client/app/config/steps/all.coffee#L12) if you want it in 2nd place.


### 2. Add config file

Create a file with the right name.
ie. `client/app/config/steps/newStep.coffee`.

Be careful `name`, `route` and `view` properties are required!


### 3. Add markup

Create a file with the right name.
ie. `client/app/views/templates/view_steps_newStep.jade`

Add markup needed into a template.


# How to add a `new method`?

If you need to add a new method not handled by `lib/onboarding`, you should :


### 1. Add new to model wrapper
Add the method to step model such as [here] (https://github.com/cozy/cozy-proxy/blob/6e92cde0d5f382008098f8ddf993628c1b202f5d/client/app/models/step.coffee#L21) with `submit method`.

Then call [`step.myNewMethod`](https://github.com/cozy/cozy-proxy/blob/6e92cde0d5f382008098f8ddf993628c1b202f5d/client/app/models/step.coffee#L26) into this new method.

### 2. Make Onboarding use it

Add [here](https://github.com/cozy/cozy-proxy/blob/6e92cde0d5f382008098f8ddf993628c1b202f5d/client/app/lib/onboarding.coffee#L7) then name of this method into the array.

### 3. Lets go!

It's time to write your method into [your config file](https://github.com/cozy/cozy-proxy/blob/6e92cde0d5f382008098f8ddf993628c1b202f5d/client/app/config/steps/password.coffee#L13)
