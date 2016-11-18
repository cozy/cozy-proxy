'use strict';
let assert = require('chai').assert;
let fetchMock = require('fetch-mock');

describe('Step: welcome', () => {
    let jsdom;
    let WelcomeConfig;

    before(function () {
        jsdom = require('jsdom-global')();
        WelcomeConfig = require('../../../app/config/steps/welcome.coffee');
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
            WelcomeConfig.save();
            assert.ok(fetchMock.called());
            assert.equal('/register', fetchMock.lastUrl());
            assert.deepEqual(JSON.stringify({onboardedSteps: ['welcome']}),
                             fetchMock.lastOptions().body);
        });

    });
});
