# coffeelint: disable=max_line_length
module.exports =
    # error page
    "error title":             "Oops, an error has occurred"
    "error headline":          "It seems that something went wrong."
    "error reinsurance":       "Don't worry, it's probably not that bad!"
    "error temporary issue":   "The problem should be temporary, please try again in 5 minutes."
    "error try restart":       "If nothing has changed despite that, try to restart your Cozy."
    "error contact cozy team": "If the problem persists, feel free to contact the Cozy team:"
    "error contact forum":     'Ask for help on our forum:'
    "error contact email":     "Send an email to contact@cozycloud.cc"
    "error contact irc":       "Report the issue on IRC, #cozycloud on irc.freenode.net"
    "error wait a bit":        "Wait for 5 minutes"
    "error restart app":       """Restart the app ("Manage your apps" menu)"""
    "error reinstall app":     "Reinstall the app"

    # error page -- not found
    "error not found info": "You are trying to access an app that is either not installed or currently being installed."

    # error page -- error app
    "error try to fix":        "You can use the following steps to try and fix the problem:"
    "error contact developer": "If nothing worked, you can contact the developer of the app or the Cozy team:"

    # error page -- public app
    "error public info": "Please wait for 5 minutes, then contact the Cozy owner if nothing has changed!"

    # errors
    "error server":               "An internal error occurred."
    "error bad credentials":      "Incorrect password."
    "error keys not initialized": "The keys aren't initialized."
    "error login failed":         "Login failed."

    # reset password email
    "reset password email from":    "Your Cozy <no-reply@%{domain}>"
    "reset password email subject": "[Cozy] Resetting your password"
    "reset password email text":    """
        It seems that you forgot the password to your Cozy.
        Not to worry, simply follow the link below to create a new one:

        https://%{domain}/password/reset/%{key}

        Don't forget to update all your encrypted data afterwards!
    """

    # validation errors
    "invalid email format": "Your email address seems to be invalid."
    "invalid timezone": "This timezone is invalid. Please use a <Continent>/<Country> format, e.g. America/New_York."
    "password too short": "Your password is too short, it should contain at least 8 characters."
