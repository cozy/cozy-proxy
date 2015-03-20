should = require('chai').Should()

path = require 'path'


mockery = require 'mockery'

cozyInstanceMock =
        getDomain: (callback) ->
            callback null, "cozy.cozycloud.cc"
        getLocale: (callback)->
            console.log "getLocaleMock"
            callback null, "fr"


applicationMock = domainSlug: (hostname, callback) ->
        if hostname is "cozyblog.cozycloud.cc"
            callback null, "blog"
        else
            callback null, ""

mockery.registerMock path.join(__dirname, '../server/models/instance'), cozyInstanceMock
mockery.registerMock path.join(__dirname, '../server/models/application'), applicationMock

middleware = null

describe "Middleware subdomain", =>

    before ->
        console.log "before"
        mockery.enable(
            warnOnReplace: false
            warnOnUnregistered: false
            useCleanCache: true
        )
        mockery.resetCache();
        middleware = require path.join __dirname, '../server/middlewares/subdomains'

    after ->
        console.log "after"
        mockery.disable()

    it "do nothing if the request is normal", (done) ->
        req =
            url: "/public/blog/"
            headers:
                host: "cozy.cozycloud.cc"

        middleware req, null, ->
            console.log req
            req.url.should.be.equal "/public/blog/"
            done()

    it "do nothing if the domain is not registered", (done) ->
        req =
            url: "/public/blog/"
            headers:
                host: "blog.cozycloud.cc"

        middleware req, null, ->
            req.url.should.be.equal "/public/blog/"
            done()

    it "modify url if the domain is registered in an app", (done) ->

        req =
            url: "/"
            headers:
                host: "cozyblog.cozycloud.cc"

        middleware req, null, ->
            req.url.should.be.equal "/public/blog/"
            done()

