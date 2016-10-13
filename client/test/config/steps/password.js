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

        it('should return `null`', () => {
            const data = {
                'password': 'plop'
            }
            assert.equal(null, PasswordConfig.validate(data))
        });

        it('Should return {errors} when `data` is empty', () => {
            let error = PasswordConfig.validate({});
            assert.equal('password', error.type);
        });
    });


    describe('#save', () => {

        it('should send POST request', () => {
            // Define global.jQUery
            // so that configPassword could use it
            sinon.stub(global.jQuery, 'post');
            let data = { email: '', password: 'plop', timezone: TimeZones[0]}
            PasswordConfig.save(data);

            data = JSON.stringify(data);

            let spyArgument = global.jQuery.post.getCalls(0)[0].args[0];

            assert(global.jQuery.post.calledOnce);
            assert.equal('/register', spyArgument.url);
            assert.deepEqual(data, spyArgument.data);

            global.jQuery.post.restore();
        });

    });


    describe('#submit', () => {

        it('should send POST request', () => {
            global.jQuery.post = sinon.spy()
            let data = { email: '', password: 'plop', timezone: TimeZones[0]}
            PasswordConfig.submit(data);

            data = JSON.stringify(data);
            assert(global.jQuery.post.calledOnce);
            assert(global.jQuery.post.calledWith('/register', data));
        });

    });
});
