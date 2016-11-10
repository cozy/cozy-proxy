'use strict';

describe('Password Stories', () => {

    let assert;
    let sinon;

    let onboarding;
    let currentIndex;
    let spyPasswordValidate;
    let spyPasswordSubmit;

    let StepModel;


    before(() => {
        assert = require('chai').assert;
        sinon = require('sinon');
        StepModel = require('../../app/models/step.coffee');

        const Onboarding = require('../../app/lib/onboarding.coffee');
        const Steps = require('../../app/config/steps/all.coffee');

        // No need to send a POST request to the server
        // we just need to know if inner workflow works
        // when data is OK or not
        const PasswordStep = require('../../app/config/steps/password.coffee');
        PasswordStep.submit = (data, success, error) => { success(data); }
        spyPasswordSubmit = sinon.spy(PasswordStep, 'submit');
        spyPasswordValidate = sinon.spy(PasswordStep, 'validate');

        // Initialize Onboarding
        onboarding = new Onboarding({}, Steps);
    })


    describe('Add a password', () => {
        let passwordStep;
        let passwordStepIndex;
        let nextStep;

        beforeEach(() => {
            const jsdom = require('jsdom-global')();
            global.jQuery = require('jquery');

            // Select password step
            onboarding.goToStep(onboarding.getStepByName('password'));

            passwordStep = onboarding.getStepByName('password');
            passwordStepIndex = onboarding.steps.indexOf(passwordStep);
            nextStep = onboarding.steps[passwordStepIndex+1];
        });

        afterEach(() => {
            // Select 1rst step
            currentIndex = undefined;

            // Reset spy
            global.jQuery.post.restore();
        });


        it('should go to `nextStep`', (done) => {
            sinon.stub(global.jQuery, 'post');
            global.jQuery.post.yieldsTo('success', {success: true});


            // Select StepPassword
            onboarding.goToStep(passwordStep);

            // Submit password value
            passwordStep.submit({ password: 'toto' })

            // Deal with async Promise call
            setTimeout(() => {
                assert.deepEqual(onboarding.getCurrentStep(), nextStep);
                done()
            }, 10);
        });


        it('shouldnt change currentStep when errors', (done) => {
            sinon.stub(global.jQuery, 'post').returns(false);
            global.jQuery.post.yieldsTo('error');

            // Select StepPassword
            onboarding.goToStep(passwordStep);

            // Submit password value
            passwordStep.submit({ password: 'toto' })

            // Deal with async Promise call
            setTimeout(() => {
                assert.deepEqual(onboarding.getCurrentStep(), passwordStep);
                done()
            }, 10);

        });
    });

});
