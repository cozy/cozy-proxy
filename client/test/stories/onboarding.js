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
            // Select 1rst step
            currentIndex = 3;
            onboarding.goToStep(onboarding.steps[currentIndex]);
        });


        it('should go to `nextStep` when password is OK', () => {
            const passwordStep = onboarding.steps[currentIndex];
            const nextStep = onboarding.steps[currentIndex + 1];

            // Select StepPassword
            onboarding.goToStep(passwordStep);
            assert.deepEqual(passwordStep, onboarding.currentStep)

            // Submit password value
            passwordStep.submit({ password: 'toto' })
            assert.deepEqual(nextStep, onboarding.currentStep)
        });


        it.skip('shouldnt go to `nextStep` when errors');
    });

});
