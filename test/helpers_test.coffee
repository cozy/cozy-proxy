bcrypt = require 'bcrypt'
helpersTest = require './helpers'
helpers = require "#{helpersTest.prefix}server/lib/helpers"
should = require('chai').Should()

describe 'helpers', ->

    describe 'checkEmail', ->
        it 'Check good email', ->
            helpers.checkEmail("test@cozycloud.cc").should.be.ok

        it 'Check wrong email', ->
            helpers.checkEmail("testcozycloud.cc").should.not.be.ok
            helpers.checkEmail("test@cozycloudcc").should.not.be.ok
            helpers.checkEmail("testcozycloudcc").should.not.be.ok
