## Onboarding component

### Modelisation naive diagram
```
—————————————————————————————-
| StateModel (agnostic)						|
—————————————————————————————-
| >> Update model value						|
| >> Trigger events related to changes				|
| ie. trigger `onboardingModel:change`			|
—————————————————————————————-
	|			^	 
	| 			|
	|			|
	|			|
	|		——————————————————————————-
	|		| StateController (i.e. on boarding)			|
	|		| @state = new StateModel(step)				|
	|		| @ doSelectStep: (data) -> @state.set(data)		|
	|		——————————————————————————-
	|			^
	|			|
	^			|
—————————————————————————————-
| StateView 								|
| @controller = new StateController()				|
——————————-———————————————————
| >> ListenTo StateModel						|
| ie. on ‘onboardingModel:change’, @doChange		|
|									|
| >> Display Actions						|
| ie. doSomething: -> @controller. doSelectStep(data)	|
——————————-———————————————————
```


### Onboarding Controller `./lib/onboarding`

It manages navigation between each step of user onboarding.

This file contains two class `<class> StateModel` and  `<class> StateController`.

`<class> StateController` able to:
 - make actions to update `StateModel`,
 - or get values from `StateModel`.

It is framework agnostic to make migration easier with other frameworks later.


### Onboarding Models `./lib/onboarding/models`

Each step is described into its own configuration file by properties and specific methods if needed.

ie. `./lib/onboarding/models`
````
module.exports = {
    name: 'agreement',
    route: 'agreement',
    view : './views/steps/agreement'
    props: {
        validate: (data) -> return data
    }
}
````

#### Step class

The class represents an onboarding step, for example the greetings step or the password definition step.

It takes as parameter a simple JavaScript object described in previous paragraph.
It also ensures that each step will have defaults mandatory methods like `submit`.

Howerver, it will be possible to override class methods in config objects (not implemented yet).

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
