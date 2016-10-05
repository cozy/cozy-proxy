## Onboarding component

### Onboarding class

This class, located in `lib/onboarding`, is an agnostic and framework free onboarding manager. It manages the different steps of onboarding and handle event triggered by steps object.

This class has to facilitate migration to another framework in the future. At this time, the framework used is Backbone/Marionette and Onboarding is implemented like a classical POO object.

## Step class

The class represents an onboarding step, for example the greetings step or the password definition step.

It's in charge of describing what a step have to do and how it may do that.
The main idea is to be able to describe what the onboarding steps are showing/containing in external files, and to easily integrates them in the onboarding engine.

## Methods
### Onboarding
#### initialize(user, steps)
Set the user and the steps list for the current onboarding.
Called by the constructor method.
The steps list should look like :
```javascript
[{
    name: 'Step 1', // Name should be unique
    route: 'step1', // URL segment
    views: 'steps/step1' // path to the view, but maybe it is too much  framework-specific and we should compute the view's path.
},{
    name: 'Step 2',
    route: 'step2',
    views: 'steps/step2'
}]
```

#### onStepChanged(callback)
##### Parameters
* `callback`: function

Record the function callback as handler for every time the current onboarding step will change.

#### goToNext()
Select the next step on the list and trigger the related events.

#### goToStep(step)
##### Parameters
* `step`: Step

Go directly to the given step and trigger required events. Useful for go back in onboarding.

#### getStepByName(stepName)
##### Parameters
* `stepName`: String

Returns a step by its name.

### Step
#### onSubmitted(callback)
##### Parameters
* `callback`: function

Add the given callback to the list of handlers to call when a step is submitted.

#### submit()
Submit the step, i.e. try to register it as done. This method should be overriden in config steps to manage specific submits or validation, for steps with forms for example.
Also, maybe it should return a Promise to handle correctly remote synchronisation.
