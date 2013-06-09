bcrypt = require 'bcrypt'
helpers = require '../helpers'


describe 'helpers', ->
    describe 'genResetKey', ->
        it 'When you generate a key', ->
            @key = helpers.genResetKey()

        it 'Then it is 32 chars long', ->
            @key.length.should.equal 32

    describe 'checkMail', ->
        it 'Check good mail', ->
            helpers.checkMail("test@cozycloud.cc").should.be.ok

        it 'Check wrong mail', ->
            helpers.checkMail("testcozycloud.cc").should.not.be.ok
            helpers.checkMail("test@cozycloudcc").should.not.be.ok
            helpers.checkMail("testcozycloudcc").should.not.be.ok
