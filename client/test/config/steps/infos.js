'use strict';
let assert = require('chai').assert;

let infos = require('../../../app/config/steps/infos.coffee');

describe('Step: infos', () => {
    describe('#isActive', () => {
        it('should return true for user.hasValidInfos is false', () => {
            // arrange
            let user = {
                hasValidInfos: false
            };

            // act
            let result = infos.isActive(user);

            // assert
            assert.isTrue(result);
        });

        it('should return false for user.hasValidInfos is true', () => {
            // arrange
            let user = {
                hasValidInfos: true
            };

            // act
            let result = infos.isActive(user);

            // assert
            assert.isFalse(result);
        });
    });
})
