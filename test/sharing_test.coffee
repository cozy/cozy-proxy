should    = require('chai').Should()
_         = require 'lodash'
sinon     = require 'sinon'
helpers   = require './helpers'
rewire    = require 'rewire'
urlHelper = require 'cozy-url-sdk'
httpMocks = require 'node-mocks-http'
events    = require 'events'

sharing      = rewire  "#{helpers.prefix}server/controllers/sharing"
remoteAccess = require "#{helpers.prefix}server/lib/remote_access"

# Proxy
client = helpers.getClient()

# Connect to the Data-System with the credentials of the Proxy
Client = require('request-json').JsonClient
clientDS = new Client urlHelper.dataSystem.url()
clientDS.setBasicAuth "proxy", "token"


describe 'sharing unit tests', ->

    before helpers.startApp

    after  helpers.stopApp

    # correct objects
    sharing_request =
        desc        : 'New mission order'
        rules       : [{id: 7, docType: 'event'}]
        sharerUrl   : 'm@mi6.cozy.uk'
        recipientUrl: 'james-bond@mi6.cozy.uk'
        preToken    : 'agent-007'
        shareID     : 18


    describe.skip 'createSharing inner module', ->

        createSharing = sharing.__get__ "createSharing"

        it 'When a sharing document is created', (done) ->
            createSharing sharing_request, (err, docInfo) =>
                should.not.exist err
                @docInfo = docInfo
                done()

        it 'then a new document is inserted in the database', (done) ->
            should.exist @docInfo._id
            done()


    describe.skip 'revokeFromRecipient inner module', ->

        # we are a sharer and one of the targets has canceled the share
        sharing_doc =
            docType   : "Sharing"
            desc      : "Community of the ring"
            rules     : [{id: 1003, docType: "event"}]
            continuous: true
            targets   : [{recipientUrl: "gimly"  , token: "dwarf"},
                         {recipientUrl: "legolas", token: "elf"},
                         {recipientUrl: "boromir", token: "human"}]

        target_to_remove = {recipientUrl: "boromir"}

        # insert document into database
        before (done) ->
            clientDS.post "data/", sharing_doc, (err, res, docInfo) ->
                sharing_doc._id = docInfo._id
                done()

        revokeFromRecipient = sharing.__get__ 'revokeFromRecipient'

        it 'When a target cancels a share', (done) ->
            revokeFromRecipient sharing_doc, target_to_remove, (err) ->
                should.not.exist err
                done()

        it 'Then its entry is removed from the sharing document', (done) ->
            clientDS.get "data/#{sharing_doc._id}", (err, res) ->
                doc = JSON.parse(res.body)
                should.exist doc.targets
                for target in doc.targets
                    target.should.not.deep.equal target_to_remove
                done()

        it 'When a target is not concerned, an error is returned', (done) ->
            revokeFromRecipient sharing_doc, {recipientUrl: 'Bilbo'}, (err) ->
                error = new Error "Bilbo not found for this sharing"
                error.status = 404
                err.should.deep.equal err
                done()


    describe 'rateLimiter module', ->

        it 'When rateLimiter is called 200 times no error is returned',
        (done) ->
            i = 0
            while i < 200
                sharing.rateLimiter {}, {}, (err) ->
                    should.not.exist err
                i++
            done()

        it 'When rateLimiter is called once more an error is returned',
        (done) ->
            sharing.rateLimiter {}, {}, (err) ->
                error = new Error "Too many requests. Please try later"
                error.status = 429
                err.should.deep.equal error
                done()


    describe 'request module', ->

        req = httpMocks.createRequest
            method: 'POST'
            url   : 'services/sharing/request'
            body  :
                desc        : 'New mission order'
                rules       : [{id: 7, docType: 'event'}]
                sharerUrl   : 'm@mi6.cozy.uk'
                recipientUrl: 'james-bond@mi6.cozy.uk'
                preToken    : 'agent-007'
                shareID     : 18

        res = httpMocks.createResponse
            eventEmitter: events.EventEmitter

        error        = new Error "Bad request"
        error.status = 400

        it 'When a request is made without a shareID an error is returned',
        (done) ->
            req_copy = _.cloneDeep req
            delete req_copy.body.shareID

            sharing.request req_copy, res, (err) ->
                should.not.exist req_copy.body.shareID
                err.should.deep.equal error
                done()

        it 'When a request is made without a sharerUrl an error is returned',
        (done) ->
            req_copy = _.cloneDeep req
            req_copy.body.sharerUrl = null

            sharing.request req_copy, res, (err) ->
                err.should.deep.equal error
                done()

        it 'When a request is made without a recipientUrl an error is returned',
        (done) ->
            req_copy = _.cloneDeep req
            req_copy.body.recipientUrl = ''

            sharing.request req_copy, res, (err) ->
                err.should.deep.equal error
                done()

        it 'When a request is made without rules an error is returned',
        (done) ->
            req_copy = _.cloneDeep req
            req_copy.body.rules = undefined

            sharing.request req_copy, res, (err) ->
                err.should.deep.equal error
                done()

        it 'When a request is made without a desc an error is returned',
        (done) ->
            req_copy = _.cloneDeep req
            req_copy.body.desc = ""

            sharing.request req_copy, res, (err) ->
                err.should.deep.equal error
                done()

        it 'When a request is made without a preToken an error is returned',
        (done) ->
            req_copy = _.cloneDeep req
            req_copy.body.preToken = ""

            sharing.request req_copy, res, (err) ->
                err.should.deep.equal error
                done()

        it 'When a request is made with a rule having no id an error is
        returned', (done) ->
            req_copy = _.cloneDeep req
            req_copy.body.rules = [{id: 1, docType: 'event'}, {docType: 'task'}]

            sharing.request req_copy, res, (err) ->
                err.should.deep.equal error
                done()

        it 'When a request is made with a rule having no docType an error is
        returned', (done) ->
            req_copy = _.cloneDeep req
            req_copy.body.rules = [{id: 1, docType: 'event'},\
                                   {id: 2, docType: ''}]

            sharing.request req_copy, res, (err) ->
                err.should.deep.equal error
                done()

        it.skip 'When a correct request is made then 200 is returned', (done) ->
            sharing.request req, res, ->
            res.on 'send', ->
                res.statusCode.should.equal 200
                done()


    describe.skip 'revoke module', ->

        req = httpMocks.createRequest
            method : 'DELETE'
            url    : 'services/sharing'
            headers:
                authorization: "1:A ring to rule them all"

        stubIsAuthenticated = {}

        before (done) ->
            stubIsAuthenticated = sinon.stub remoteAccess,
                'isAuthenticated', (header, callback) ->
                    callback false

            done()

        after (done) ->
            stubIsAuthenticated.restore()
            done()


        it 'When an unauthorized request is made an error is returned',
        (done) ->
            sharing.revoke req, {}, (err) ->
                error        = new Error "Request unauthorized"
                error.status = 401
                err.should.deep.equal error
                done()


    describe 'revokeTarget module', ->

        sharing_doc =
            docType   : "Sharing"
            desc      : "Community of the ring"
            rules     : [{id: 1003, docType: "event"}]
            continuous: true
            targets   : [{recipientUrl: "gimly"  , token: "dwarf"},
                         {recipientUrl: "legolas", token: "elf"},
                         {recipientUrl: "boromir", token: "human"}]

        target_to_remove = {recipientUrl: "boromir"}

        # Req is not used but it gives an idea of what it looks like normally
        req = httpMocks.createRequest
            method: 'DELETE'
            url   : 'services/sharing/target'
            header: 'boromir:human'

        res = httpMocks.createResponse
            eventEmitter: events.EventEmitter

        # Stub the modules used from ../lib/remote_access.coffee
        stubExtractCredentials    = {}
        stubIsTargetAuthenticated = {}

        before (done) ->
            stubExtractCredentials = sinon.stub remoteAccess,
                'extractCredentials', (header) ->
                    ["boromir", "human"]

            stubIsTargetAuthenticated = sinon.stub remoteAccess,
                'isTargetAuthenticated', (credential, callback) ->
                    callback true, sharing_doc, target_to_remove

            done()

        after  (done) ->
            stubExtractCredentials.restore()
            stubIsTargetAuthenticated.restore()
            done()


        it.skip 'When a successful authorized request is made then 200 is returned',
        (done) ->
            # since no error should be returned then there is no callback made
            sharing.revokeTarget req, res
            # hence we capture the express logic with res
            res.on 'send', ->
                res.statusCode.should.equal 200
                done()

        it 'When an unauthorized request is made an error is returned',
        (done) ->
            stubIsTargetAuthenticated.restore() # cancel default stub
            stubIsTargetAuthenticated = sinon.stub remoteAccess,
                'isTargetAuthenticated', (credential, callback) ->
                    callback false, sharing_doc, target_to_remove

            sharing.revokeTarget req, res, (err) ->
                error        = new Error "Request unauthorized"
                error.status = 401
                err.should.deep.equal error
                done()

        it 'When `revokeFromRecipient` fails an error is returned', (done) ->
            stubIsTargetAuthenticated.restore() # cancel previous stub
            stubIsTargetAuthenticated = sinon.stub remoteAccess,
                'isTargetAuthenticated', (credential, callback) ->
                    callback true, sharing_doc, {recipientUrl: 'Hagrid'}

            sharing.revokeTarget req, res, (err) ->
                error        = new Error "Cannot revoke the recipient"
                error.status = 400
                err.should.deep.equal error
                done()


    describe 'answer module', ->

        # Express logic: req and res
        req = httpMocks.createRequest
            url   : 'services/sharing/answer'
            method: 'POST'
            body  :
                recipientUrl: 'james-bond@mi6.cozy.uk'
                accepted    : true
                token       : 'my_name_is_bond'

        res = httpMocks.createResponse
            eventEmitter: events.EventEmitter

        # stub of modules defined in remoteAccess
        stubExtractCredentials    = {}
        stubIsTargetAuthenticated = {}


        # This error will be used in the first three tests so here it is
        error        = new Error "Bad request"
        error.status = 400


        before (done) ->
            stubExtractCredentials = sinon.stub remoteAccess,
                'extractCredentials', (header) -> return ["18", "agent-007"]
            stubIsTargetAuthenticated = sinon.stub remoteAccess,
                'isTargetAuthenticated', (credential, callback) ->
                    callback true

            done()

        after  (done) ->
            stubExtractCredentials.restore()
            stubIsTargetAuthenticated.restore()
            done()


        it 'When recipientUrl is missing an error is returned', (done) ->
            req_copy = _.cloneDeep req
            req_copy.body.recipientUrl = ''

            sharing.answer req_copy, res, (err) ->
                err.should.deep.equal error
                done()

        it 'When accepted is missing an error is returned', (done) ->
            req_copy = _.cloneDeep req
            delete req_copy.body.accepted

            sharing.answer req_copy, res, (err) ->
                err.should.deep.equal error
                done()

        it 'When accepted is true and token is missing then an error is
        returned', (done) ->
            req_copy = _.cloneDeep req
            req_copy.body.token = null

            sharing.answer req_copy, res, (err) ->
                err.should.deep.equal error
                done()

        it 'When an unauthorized request is made then an error is returned',
        (done) ->
            stubIsTargetAuthenticated.restore() # cancel hook stub
            stubIsTargetAuthenticated = sinon.stub remoteAccess,
                'isTargetAuthenticated', (credential, callback) ->
                    callback false

            sharing.answer req, res, (err) ->
                error        = new Error "Request unauthorized"
                error.status = 401
                err.should.deep.equal error
                done()


    describe 'replication module', ->

        # Express logic
        req = httpMocks.createRequest
            url    : 'services/sharing/replication'
            method : 'POST'
            headers:
                authorization: 'james-bond@mi6.cozy.uk:my_name_is_bond'

        stubIsAuthenticated = {}

        before (done) ->
            stubIsAuthenticated = sinon.stub remoteAccess,
                'isAuthenticated', (credentials, callback) ->
                    callback false

            done()

        after (done) ->
            stubIsAuthenticated.restore()
            done()


        it 'When an unauthorized request is made then an error is returned',
        (done) ->
            sharing.replication req, {}, (err) ->
                error        = new Error "Request unauthorized"
                error.status = 401
                done()

