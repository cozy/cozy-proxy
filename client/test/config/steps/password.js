'use strict';
let assert = require('chai').assert;

let PasswordConfig = require('../../../app/config/steps/password.coffee');
let TimeZones = require('../../../app/lib/timezones.coffee');

describe('Step: password', () => {

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
});
