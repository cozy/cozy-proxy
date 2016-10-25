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
            let data = {password: 'plop',
              onboardedSteps: ['welcome', 'password']
            }
            PasswordConfig.save(data);

            data = JSON.stringify(data);

            let spyArgument = global.jQuery.post.getCalls(0)[0].args[0];

            assert(global.jQuery.post.calledOnce);
            assert.equal('/register', spyArgument.url);
            assert.deepEqual(data, spyArgument.data);

            global.jQuery.post.restore();
        });

    });
});
