'use strict';
let assert = require('chai').assert;
let sinon = require('sinon');


describe('Step: password', () => {

    let jQuery;
    let jsdom;
    let PasswordConfig;
    let TimeZones;


    before(function () {
      jsdom = require('jsdom-global')();
      global.jQuery = require('jquery');
      PasswordConfig = require('../../../app/config/steps/password.coffee');
      TimeZones = require('../../../app/lib/timezones.coffee');
    });

    after(function () {
      jsdom();
    });


    describe('#validate', () => {

        it('should return null', () => {
            // Empty cases
            assert.equal(null, PasswordConfig.validate({}))
            assert.equal(null, PasswordConfig.validate())
            assert.equal(null, PasswordConfig.validate(''))

            let data = { email: '', password: 'plop', timezone: TimeZones[0]}
            assert.equal(null, PasswordConfig.validate(data))
        });

        it.skip('should return [errors]', () => {

        });
    });


    describe('#submit', () => {

        it('should send POST request', () => {
            // Define global.jQUery
            // so that configPassword could use it
            global.jQuery.post = sinon.spy()
            let data = { email: '', password: 'plop', timezone: TimeZones[0]}
            PasswordConfig.submit(data);

            data = JSON.stringify(data);
            assert(global.jQuery.post.calledOnce);
            assert(global.jQuery.post.calledWith('/register', data));
        });

    });
});
