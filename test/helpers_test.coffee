bcrypt = require 'bcrypt'
redis = require 'redis'
helpers = require '../helpers'


describe 'helpers', ->
    describe 'genResetKey', ->
        it 'When you generate a key', ->
            @key = helpers.genResetKey()

        it 'Then it is stored in Redis', (done) ->
            client = redis.createClient()
            client.get 'resetKey', (err, res) =>
                res.should.equal @key
                done()

    describe 'checkKey', ->
        it 'Check a good key', (done) ->
            helpers.checkKey @key, (err, isKey) ->
                isKey.should.be.ok
                done()

        it 'Check a wrong key', (done) ->
            helpers.checkKey 'wrong', (err, isKey) ->
                isKey.should.not.be.ok
                done()

    describe 'checkMail', ->
        it 'Check good mail', ->
            helpers.checkMail("test@cozycloud.cc").should.be.ok

        it 'Check wrong mail', ->
            helpers.checkMail("testcozycloud.cc").should.not.be.ok
            helpers.checkMail("test@cozycloudcc").should.not.be.ok
            helpers.checkMail("testcozycloudcc").should.not.be.ok
