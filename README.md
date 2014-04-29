
# [Cozy](http://cozy.io) Proxy

Cozy Proxy redirects requests properly to the right application of the Cozy
platfomr depending on given path. It also handles authentication to the Cozy
for users and devices.

## Install

We assume here that the Cozy platform is correctly [installed](https://raw.github.com/mycozycloud/cozy-setup/gh-pages/assets/images/happycloud.png)
 on your server.

Type this command to install the proxy module:

    cozy-monitor install proxy

## Contribution

You can contribute to the Cozy Proxy in many ways:

* Pick up an [issue](https://github.com/mycozycloud/cozy-proxy/issues?state=open) and solve it.
* Translate it in [a new language](https://github.com/mycozycloud/cozy-proxy/tree/master/client/app/locales).
* Improve the session management.

## Hack

To be hacked, the Cozy Proxy dev environment requires that a CouchDB instance
and a Cozy Data System instance are running. Then you can start the Cozy Proxy
this way:

    git clone https://github.com/mycozycloud/cozy-proxy.git
    node server.js

Each modification requires a new build, here is how to run a build:

    cake build

## Tests

![Build
Status](https://travis-ci.org/mycozycloud/cozy-proxy.png?branch=master)

To run tests type the following command into the Cozy Home folder:

    cake tests

## Icons

by [iconmonstr](http://iconmonstr.com/)

## License

Cozy Proxy is developed by Cozy Cloud and distributed under the AGPL v3 license.

## What is Cozy?

![Cozy Logo](https://raw.github.com/mycozycloud/cozy-setup/gh-pages/assets/images/happycloud.png)

[Cozy](http://cozy.io) is a platform that brings all your web services in the
same private space.  With it, your web apps and your devices can share data
easily, providing you with a new experience. You can install Cozy on your own
hardware where no one profiles you. 

## Community 

You can reach the Cozy Community by:

* Chatting with us on IRC #cozycloud on irc.freenode.net
* Posting on our [Forum](https://groups.google.com/forum/?fromgroups#!forum/cozy-cloud)
* Posting issues on the [Github repos](https://github.com/mycozycloud/)
* Mentioning us on [Twitter](http://twitter.com/mycozycloud)
