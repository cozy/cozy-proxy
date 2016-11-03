# Onboarding : user data handling

## Existing

### Model

```coffee
email: String
password: String
salt: String
public_name: String
timezone: String
owner: Boolean
allow_stats: Boolean
activated: Boolean
encryptedOtpKey: String
hotpCounter: Number
authType: String
encryptedRecoveryCodes: Array
```

### Process

1. Checking ```public_name ``` property existance from ```user``` document (server side).
2. __If__ ```public_name ``` __exists__, redirection to ```login``` page. __Otherwise__, rendering the front application with, as default, the ```register``` page in order to save ```user``` data.
3. __If register__, new data for the ```user``` document are saved at the form validation, then redirection to the ```login``` page.

### Issues

* The ```user``` document isn't fully obtained from the server, since all informations are not necessary here for the ```register```.
* The "choice" between ```register``` and ```login``` is only based on the ```public_name ``` property existance (```user``` document).
* The ```register``` step is processed only __BEFORE__ the user authentication, which doesn't allow to expose all ```user``` document data.

## Proposition

### Model

```coffee
email: String
password: String
salt: String
public_name: String
timezone: String
owner: Boolean
allow_stats: Boolean
activated: Boolean
encryptedOtpKey: String
hotpCounter: Number
authType: String
encryptedRecoveryCodes: Array
# new fields below
onboardedSteps: Array
# default: []
# complete: ['welcome', 'agreement', 'password', 'infos', 'accounts', 'ending']
isCGUaccepted: Boolean
# default: false
```

### Constraints

* The ```user``` document data mustn't be exposed before user authentication, except ```public_name ``` string and ```hasValidInfos``` boolean only.
* The existing ```login``` mustn't be broken before its specific refactoring later on.
* The user can not get back to the previous step.
* Some steps are reachable only with user authentication : ```infos```, ```accounts``` and ```ending```
* __Security purpose:__ A token could be used to get reachable the first three onboarding steps, in a secured way and with a unique usage.

### Processes

This process handles the case detection from the ```user``` document and all redirections between onboarding steps and other elements (login page, the cozy home and My Accounts application).

The complete ```onboardedSteps``` value, considered here, is ```['welcome', 'agreement', 'password', 'infos', 'accounts', 'ending']```

> Legend:
> '__=>__' means "__redirect to | go to__"

#### Step situation detection

According to the ```user``` document properties:

* If __```onboardedSteps```__ is __```['welcome']```__ => ```agreement``` step.
* If __```onboardedSteps```__ is __```['welcome', 'agreement']```__ => ```password``` step.
* If ```isCGUaccepted``` AND ```password``` AND __```onboardedSteps```__ is __```['welcome', 'agreement', 'password']```__ => ```login``` then ```infos``` step to get ```email``` and ```timezone``` informations.
* If ```isCGUaccepted``` AND ```password``` AND ```email``` AND ```timezone``` AND ```public_name``` AND __```onboardedSteps```__ is __```['welcome', 'agreement', 'password']```__ => ```login``` then ```accounts``` step with ```onboardedSteps``` set to ```['welcome', 'agreement', 'password', 'infos']``` (skip unecessary ```infos``` step)
* If __```onboardedSteps```__ is __```['welcome', 'agreement', 'password', 'infos']```__ => ```accounts``` step with user authenticated
* If __```onboardedSteps ```__ is __```['welcome', 'agreement', 'password', 'infos', 'accounts']```__ => ```ending``` step with authenticated user
* If __```onboardedSteps ```__ is __```['welcome', 'agreement', 'password', 'infos', 'accounts', 'ending']```__ => cozy home with authenticated user
* If no ```user``` document => ```welcome``` step (without username)
* If only ```public_name``` => ```welcome``` step (with username)
* __Default__ => ```welcome``` step with ```onboardedSteps``` set to ```[]```

#### Views data behaviour (client side)

> ```hasValidInfos``` is a boolean used here to know if the onboarding will have 5 or 6 steps (if the user will need the ```infos``` step or not), specially for the progress indicator feature.

1. For ```welcome``` step:
    * Reachable via ```/onboarding/welcome``` path
    * Only the ```username``` and ```hasValidInfos``` (if exist) are used throught the view
    * At validation, ```welcome``` step name are sent to server side to be saved in user ```user``` document (```onboardedSteps``` property)
    * __Save request__ format:
        ```
        POST /register
        {
            "onboardedSteps": Array(String)
        }
        ```
2. For ```agreement``` step:
    * Reachable via ```/onboarding/agreement``` path
    * Only the ```username``` and ```hasValidInfos``` (if exist) are used throught the view
    * At validation, ```agreement``` step name and ```{CGUaccepted: true}``` are sent to server side to be saved in ```user``` document
    * __Save request__ format:
        ```
        POST /register
        {
            "isCGUaccepted": Boolean,
            "allow_stats": Boolean,
            "onboardedSteps": Array(String)
        }
        ```
3. For ```password``` step:
    * Reachable via ```/onboarding/password``` path
    * Only the ```username``` and ```hasValidInfos``` (if exist) are used throught the view
    * At validation, ```password``` step name and ```{password: 'userpasswordhere'}``` are sent to server side to be saved in ```user``` document
    * At the validation, the user will be redirected to the login page for the authentication
    * __Save request__ format:
        ```
        POST /register
        {
            "password": String,
            "onboardedSteps": Array(String)
        }
        ```
4. For ```infos``` step:
    * User __authentication required__
    * Reachable via ```/onboarding/infos``` path
    * At the step rendering, the ```user``` document is requested
    * At validation, ```infos``` step name and ```{email: 'userpasswordhere', public_name: 'username', timezone: 'country/town'}``` are sent to server side to be saved in ```user``` document
    * __Save request__ format:
        ```
        PUT /register
        {
            "public_name": String,
            "email": String,
            "timezone": String,
            "onboardedSteps": Array(String)
        }
        ```
5. For ```accounts``` step:
    * User __authentication required__
    * Reachable via ```/onboarding/accounts``` path
    * At the step validation, the user will be redirected to the "My Accounts" application (using probably an argument to specify that is from the onboarding process)
    * At the "My accounts" callback, ```accounts``` step name is sent to server side to be saved in ```user``` document
    * __Save request__ format:
        ```
        PUT /register
        {
            "onboardedSteps": Array(String)
        }
        ```
6. For the ```ending``` step:
    * User __authentication required__
    * Reachable via ```/onboarding/ending``` path
    * The step must be reachable from an URL that follows these rules:
        * If the ```onboardedSteps ``` is ```['welcome', 'agreement', 'password', 'infos', 'accounts']``` => ```ending``` step
        * If the ```activated``` is ```false``` AND ```onboardedSteps ``` is ```['welcome', 'agreement', 'password', 'infos', 'accounts', 'ending']``` => ```ending``` step
        * If the ```activated``` is ```true``` AND ```onboardedSteps ``` is ```['welcome', 'agreement', 'password', 'infos', 'accounts', 'ending']``` => cozy home
        * __Default__ => ```welcome``` step with ```onboardedSteps``` set to ```[]```
    * __Save request__ format:
        ```
        PUT /register
        {
            "onboardedSteps": Array(String)
        }
        ```

#### Handle onboarding changes

At the entry connexion (after login or at the home connexion):

* If ```activated``` is ```true```, the ```onboardedSteps``` is compared to the steps hardcoded in the cozy-proxy:
    * If it's the same => login page then the cozy home as authenticated user (__usual case__)
    * Otherwise, ```onboardedSteps``` is changed (that means the order or the steps have changed in the proxy) and the user will be redirected to a specific step (or not) according to the ```onboardedSteps``` value. This way will be used when __in case of future onboarding steps updates__.
* If ```activated``` is ```false```, see server side "Step situation detection" part
