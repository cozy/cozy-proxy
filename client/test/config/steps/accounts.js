'use strict';
let assert = require('chai').assert;

let accounts = require('../../../app/config/steps/accounts.coffee');

describe('Step: accounts', () => {
    describe('#isActive', () => {

        before(() => {
            global.ENV = {};
        });

        after(() => {
            delete global.ENV;
        });

        it('should return true is the accounts app is installed', () => {
            ENV.apps = ['konnectors'];
            assert.isTrue(accounts.isActive());
        });

        it('should return false is the accounts app is not installed', () => {
            ENV.apps= [];
            assert.isFalse(accounts.isActive());
        });
    });
})
