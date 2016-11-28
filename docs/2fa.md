## Introduction

The proxy can now authenticate using the HOTP (HMAC-based One-Time Password, or OTP with a counter) and TOTP (Timer-based One-Time Password, or OTP with a timer) algorithms through the corresponding Passport strategies in the `/server/lib/passport_configurator.coffee` file.

## Algorithms and strategies

Quick look at the algorithms and the corresponding strategies:

* **HOTP** is less compliant as you can't find it in a lot of softwares. Actually, I've only found HOTP compliance in the Google Authenticator app. However, it's more frequently found in hardware/device-based 2FA (such as the Yubikey), and its Passport strategy make it more secure (as it gives us a counter delta, we can store the current token's order in the algorithm's generation and invalidate all the previous ones, so we can really call it a one-time password).
* **TOTP** is way more frequently found in software (GAuthenticator, Authy, etc). We can't manually invalidate a token through time, but that's fine since TOTP-generated tokens are valid only within a specific time window.

In the future, the user will be able to chose which algorithme to use via a configuration panel within the Cozy home.

## Modifications to the user doctype

In order to store everything we need in the database, three fields have been added to the `User` doctype:

* `encryptedOtpKey` is the key (sort of a master password) we'll pass to the chosen Passport strategy. It's a randomly-generated alphanumeric string, which generations rules don't differ from HOTP to TOTP (and vice-versa), so we don't have to have two "key" fields. Note that the key isn't the longer and all-capitalized code you enter in your 2FA app/device, which is a base32 encoding of the key, so we don't need to store it.
* `hotpCounter` is only used when using the HOTP algorithm, to store the counter. This allows us to check wether the user enters a token with a lower counter than the last recorded one (which will mean that the entered token may have already been used) and invalidate it. It's also a necessary field required by the Passport strategy.
* `authType` stores the selected algorithms. It can be `null` or even `undefined` if the user hasn't enabled 2FA (or has disabled it), which will be understood as no 2FA authentication, or have a value corresponding to the selected Passport strategy (right now, only "hotp" and "totp" won't trigger a Passport error as only these ones are implemented).

## New authentication process

The `/server/middlewares/authentication.coffee` file has been modified so the authentication now proceeds as such:

* We receive data from the user
* We proceed to the usual password authentication
* In case of successful password-based authentication, if `authType` is null or undefined, we redirect the user to the Cozy home (usual authentication)
* In case of successful password-based authentication, if `authType` has a defined value, we proceed to the corresponding authentication (HOTP or TOTP)
* In case of a successful second authentication, we redirect the user to the Cozy home

The `authType` also allows one really useful feature: When we generate and send the login page to the user, we can modulate it according to wether or not OTP-based 2FA is enabled. This way, if this feature is disabled, the user will see the usual login page:

![capture d ecran de 2016-04-04 18-59-27](https://cloud.githubusercontent.com/assets/5547783/14256036/6136abca-fa97-11e5-8cf5-08b385dc1c9f.png)

But if the OTP-based 2FA feature is enabled (on any of the two algorithms), the user will get this login page:

![capture d ecran de 2016-04-04 19-04-00](https://cloud.githubusercontent.com/assets/5547783/14256173/1f70f406-fa98-11e5-8737-72b60b0f6cb6.png)

## One-Time password generation

The token the user will have to input will be generated via an app such as Authy or Google Authenticator. These apps will process the base32 of the master key (which is the string we'll give to the user in the configuration panel) and output a 6 digits-long token for a limited time that the user will have to enter in the "Authentication code" field.
If the chosen algorithm is HOTP, he can also retrieve the token through a dedicated device such as a Yubikey.<br />
We can also think about adding a token generation feature in the Cozy Android app, which could be great to make switching to 2FA easier.

To put this in perspective, it's the same process as the Steam Authenticator or Battle.net Authenticator apps (except these two are for specific services). Given the right information (in our case, the base32 of the master key), the app will give us a temporary token to enter.
