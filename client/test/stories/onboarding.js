'use strict';

describe('Password Stories', () => {

    let assert;
    let sinon;

    let onboarding;
    let currentIndex;


    before(() => {
        assert = require('chai').assert;
        sinon = require('sinon');

        const Onboarding = require('../../app/lib/onboarding.coffee');
        const Steps = require('../../app/config/steps/all.coffee');
        onboarding = new Onboarding({}, Steps);
    })


    describe('Add a password', () => {

        beforeEach(() => {
            const jsdom = require('jsdom-global')();
            global.jQuery = require('jquery');

            // Select password step
            onboarding.goToStep(onboarding.getStepByName('password'));
        });


        it('should go to `nextStep` when password is OK', (done) => {
            const passwordStep = onboarding.getStepByName('password');
            const passwordStepIndex = onboarding.steps.indexOf(passwordStep);
            const nextStep = onboarding.steps[passwordStepIndex+1];

            sinon.stub(global.jQuery, 'post');
            global.jQuery.post.yieldsTo('success');

            // Select StepPassword
            onboarding.goToStep(passwordStep);

            // Submit password value
            passwordStep.submit({ password: 'toto' })

            // Deal with async Promise call
            setTimeout(() => {
                assert.deepEqual(onboarding.getCurrentStep(), nextStep);
                global.jQuery.post.restore();
                done()
            }, 10);

        });


        it.skip('shouldnt go to `nextStep` when errors');
    });

});
