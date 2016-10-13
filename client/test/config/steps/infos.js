'use strict';
let assert = require('chai').assert;

let infos = require('../../../app/config/steps/infos.coffee');

describe('Step: infos', () => {
    describe('#isActive', () => {
        it('should return true for user.hasInfos is false', () => {
            // arrange
            let user = {
                hasInfos: false
            };

            // act
            let result = infos.isActive(user);

            // assert
            assert.isTrue(result);
        });

        it('should return false for user.hasInfos is true', () => {
            // arrange
            let user = {
                hasInfos: true
            };

            // act
            let result = infos.isActive(user);

            // assert
            assert.isFalse(result);
        });
    });
})
