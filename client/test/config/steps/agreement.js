'use strict';
let assert = require('chai').assert;
let fetchMock = require('fetch-mock');

describe('Step: agreement', () => {
    let jsdom;
    let AgreementConfig;

    before(function () {
        jsdom = require('jsdom-global')();
        AgreementConfig = require('../../../app/config/steps/agreement.coffee');
    });

    after(function () {
        jsdom();
    });

    afterEach(() => {
        fetchMock.restore();
    });

    describe('#save', () => {

        it('should send POST request', () => {
            fetchMock.post('*', 200);
            AgreementConfig.save({allowStats: true});
            assert.ok(fetchMock.called());
            assert.equal('/register', fetchMock.lastUrl());
            let data = {
              onboardedSteps: ['welcome', 'agreement'],
              isCGUaccepted: true,
              allow_stats: true
            }
            assert.deepEqual(JSON.stringify(data),
                             fetchMock.lastOptions().body);
        });

    });
});
