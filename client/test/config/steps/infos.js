'use strict';
let assert = require('chai').assert;

let infos = require('../../../app/config/steps/infos.coffee');

describe('Step: infos', () => {
    describe('#isActive', () => {
        it('should return true for user with invalid email', () => {
            // arrange
            let user = {
                email: '',
                timezone: 'Europe/Paris'
            };

            // act
            let result = infos.isActive(user);

            // assert
            assert.isTrue(result);
        });

        it('should return true for user with invalid timezone', () => {
            // arrange
            let user = {
                email: 'claude@example.org',
                timezone: 'not a timezone'
            };

            // act
            let result = infos.isActive(user);

            // assert
            assert.isTrue(result);
        });

        it('should return false for user with valid email and timezone', () => {
            // arrange
            let user = {
                email: 'claude@example.org',
                timezone: 'Europe/Paris'
            };

            // act
            let result = infos.isActive(user);

            // assert
            assert.isFalse(result);
        });
    });
})
