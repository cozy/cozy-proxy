# coffeelint: disable=max_line_length
module.exports =
    # error page
    "error title":             "Oups, une erreur est survenue"
    "error headline":          "Il semble que quelque chose se soit mal passé."
    "error reinsurance":       "Ne vous inquiétez pas, ce n'est probablement pas trop grave !"
    "error temporary issue":   "Le problème devrait être temporaire, merci de réessayer dans 5 minutes."
    "error try restart":       "Si rien n'a changé après ça, essayez de redémarrer votre Cozy."
    "error contact cozy team": "Si le problème persiste, n'hésitez pas à contacter l'équipe Cozy :"
    "error contact forum":     "Demandez de l'aide sur notre forum :"
    "error contact email":     "Envoyez un email à contact@cozycloud.cc"
    "error contact irc":       "Reportez le problème sur IRC, canal #cozycloud sur irc.freenode.net"
    "error wait a bit":        "Attendre 5 minutes"
    "error restart app":       """Redémarrer l'application (onglet "Gérez vos apps")"""
    "error reinstall app":     "Réinstaller l'application"

    # error page -- not found
    "error not found info": "Vous essayez d'accéder à une application qui n'est pas installée ou qui est en train d'être installée."

    # error page -- error app
    "error try to fix":        "Vous pouvez essayer les actions suivantes pour régler le problème :"
    "error contact developer": "Si rien n'a marché, vous pouvez contacter le développeur de l'application ou l'équipe Cozy :"

    # error page -- public app
    "error public info": "Veuillez attendre 5 minutes, puis contacter le propriétaire du Cozy si rien n'a changé !"

    # errors
    "error server":               "Une erreur interne est survenue."
    "error bad credentials":      "Mot de passe incorrect."
    "error keys not initialized": "Les clés ne sont pas initialisées."
    "error login failed":         "Echec de la connexion."

    # reset password email
    "reset password email from":    "Votre Cozy <no-reply@%{domain}>"
    "reset password email subject": "[Cozy] Réinitialiser votre mot de passe"
    "reset password email text":    """
        Il semble que vous ayez oublié le mot de passe de votre Cozy.
        Ne vous inquiétez pas, suivez simplement le lien suivant pour en définir un nouveau :

        https://%{domain}/password/reset/%{key}

        N'oubliez pas de mettre à jour toutes vos données chiffrées après ça !
    """

    # validation errors
    "invalid email format": "Votre adresse email ne semble pas valide."
    "invalid timezone": "Ce fuseau horaire n'est pas valide. Utilisez un format <Continent>/<Pays>, par exemple Europe/Paris."
    "password too short": "Votre mot de passe est trop court, il doit contenir au moins 8 caractères."
