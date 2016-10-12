'use strict';
let assert = require('chai').assert;
let sinon = require('sinon');

let Onboarding = require('../../app/lib/onboarding.coffee');
let Step = require('../../app/lib/onboarding.coffee').Step;

describe('Onboarding', () => {

    describe('#initialize', () => {

        it('should set `user` property', () => {
            // arrange
            let user = {
                name: 'Claude',
                lastname: 'Causi'
            };

            let steps = [];

            // act
            let onboarding = new Onboarding(user, steps);

            // assert
            assert.deepEqual(onboarding.user, user);
        });

        it('should set `steps` property', () => {
            // arrange
            let user = null;
            let steps = [{
                name: 'test',
                route: 'testroute',
                view: 'testview'
            }, {
                name: 'test2',
                route: 'testroute2',
                view: 'testview2'
            }];

            // act
            let onboarding = new Onboarding(user, steps);

            // assert
            assert.isDefined(onboarding.steps);
            assert.equal(2, onboarding.steps.length);
        });

        it('should map steps objects to Steps instances', () => {
            // arrange
            let user = null;
            let steps = [{
                name: 'test',
                route: 'testroute',
                view: 'testview'
            }, {
                name: 'test2',
                route: 'testroute2',
                view: 'testview2'
            }];

            // act
            let onboarding = new Onboarding(user, steps);

            // assert
            let step1 = onboarding.steps[0];
            assert('Step', step1.constructor.name);
            assert.equal('test', step1.name);
            assert.equal('testroute', step1.route);
            assert.equal('testview', step1.view);
            assert.isFunction(step1.onValidated);
            assert.isFunction(step1.triggerValidated);
            assert.isFunction(step1.submit);

            let step2 = onboarding.steps[1];
            assert('Step', step2.constructor.name);
            assert.equal('test2', step2.name);
            assert.equal('testroute2', step2.route);
            assert.equal('testview2', step2.view);
            assert.isFunction(step2.onValidated);
            assert.isFunction(step2.triggerValidated);
            assert.isFunction(step2.submit);
        });

        it('should throw error when `steps` parameter is missing', () => {
            // arrange
            let fn = () => {
                // act
                let onboarding = new Onboarding();
            }

            // assert
            assert.throw(fn, 'Missing mandatory `steps` parameter');
        });

        it('should not map inActive steps', () => {
            // arrange
            // arrange
            let user = null;
            let steps = [{
                name: 'test',
                route: 'testroute',
                view: 'testview'
            }, {
                name: 'test2',
                route: 'testroute2',
                view: 'testview2',
                isActive: () => false
            }];

            // act
            let onboarding = new Onboarding(user, steps);

            // assert
            assert.equal(1, onboarding.steps.length)
            let step1 = onboarding.steps[0];
            assert('Step', step1.constructor.name);
            assert.equal('test', step1.name);
            assert.equal('testroute', step1.route);
            assert.equal('testview', step1.view);
        });
    });

    describe('#onStepChanged', () => {

        it('should add given callback to step changed handlers', () => {
            // arrange
            let onboarding = new Onboarding(null, []);
            let callback = (step) => {};

            // act
            onboarding.onStepChanged(callback);

            // assert
            assert.isDefined(onboarding.stepChangedHandlers);
            assert.equal(1, onboarding.stepChangedHandlers.length);
            assert.include(onboarding.stepChangedHandlers, callback);
        });

        it('should throw an error when callback is not a function', () => {
            // arrange
            let onboarding = new Onboarding(null, []);
            let randomString = 'abc';
            let fn = () => {
                // act
                onboarding.onStepChanged(randomString);
            };

            assert.throws(fn, 'Callback parameter should be a function');
        });
    });

    describe('#handleStepSubmitted', () => {
        it('should call Onboarding#goToNext', () => {
            // arrange
            let onboarding = new Onboarding(null, []);
            onboarding.goToNext = sinon.spy();

            // act
            onboarding.handleStepSubmitted(null);

            // assert
            assert(onboarding.goToNext.calledOnce);
        });
    });

    describe('#triggerStepChanged', () => {
        it('should not throw error when `stepChangedHandlers` is empty', () => {
            // arrange
            let onboarding = new Onboarding(null, [{
                name: 'test',
                route: 'testroute',
                view: 'testview'
            }, {
                name: 'test2',
                route: 'testroute2',
                view: 'testview2'
            }]);

            let stepToTrigger = onboarding.steps[0];

            let fn = () => {
                // act
                onboarding.triggerStepChanged(stepToTrigger);
            };

            // assert
            assert.doesNotThrow(fn);
        });

        it('should call registered callbacks', () => {
            // arrange
            let onboarding = new Onboarding(null, [{
                name: 'test',
                route: 'testroute',
                view: 'testview'
            }, {
                name: 'test2',
                route: 'testroute2',
                view: 'testview2'
            }]);

            let stepToTrigger = onboarding.steps[0];

            let callback1 = sinon.spy();
            let callback2 = sinon.spy();

            onboarding.onStepChanged(callback1);
            onboarding.onStepChanged(callback2);

            // act
            onboarding.triggerStepChanged(stepToTrigger);

            // assert
            assert(callback1.calledOnce);
            assert(callback2.calledOnce);
            assert(callback1.calledWith(stepToTrigger));
            assert(callback2.calledWith(stepToTrigger));

        });
    });

    describe('#goToStep', () => {
        it('should set new current step', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }
            ]);

            let firstStep = onboarding.steps[0];

            // act
            onboarding.goToStep(firstStep);

            // assert
            assert.equal(firstStep, onboarding.currentStep);
        });

        it('should call `triggerStepChanged`', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }
            ]);

            let firstStep = onboarding.steps[0];
            onboarding.triggerStepChanged = sinon.spy();

            // act
            onboarding.goToStep(firstStep);

            // assert
            assert(onboarding.triggerStepChanged.calledOnce);
            assert(onboarding.triggerStepChanged.calledWith(firstStep));
        });
    });

    describe('#goToNext', () => {
        it('should call goToStep with first step', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }
            ]);

            let firstStep = onboarding.steps[0];
            onboarding.goToStep = sinon.spy();

            // act
            onboarding.goToNext();

            // assert
            assert(onboarding.goToStep.calledOnce);
            assert(onboarding.goToStep.calledWith(firstStep));
        });

        it('should call goToStep with next step', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }, {
                    name: 'test3',
                    route: 'testroute3',
                    view: 'testview3'
                }
            ]);

            let secondStep = onboarding.steps[1];
            let thirdStep = onboarding.steps[2];
            onboarding.goToStep(secondStep);
            onboarding.goToStep = sinon.spy();

            // act
            onboarding.goToNext();

            // assert
            assert(onboarding.goToStep.calledOnce);
            assert(onboarding.goToStep.calledWith(thirdStep));
        });

        it('should call triggerDone when current step is the last one', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }, {
                    name: 'test3',
                    route: 'testroute3',
                    view: 'testview3'
                }
            ]);

            let thirdStep = onboarding.steps[2];
            onboarding.goToStep(thirdStep);
            onboarding.triggerDone = sinon.spy();

            // act
            onboarding.goToNext();

            // assert
            assert(onboarding.triggerDone.calledOnce);
        });
    });

    describe('#triggerDone', () => {
        // to implement later
    });

    describe('#getStepByName', () => {
        it('should retrieve step by its name', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }, {
                    name: 'test3',
                    route: 'testroute3',
                    view: 'testview3'
                }
            ]);

            let secondStep = onboarding.steps[1];

            // act
            let result = onboarding.getStepByName('test2');

            // assert
            assert.equal(secondStep, result);
        });

        it('should return undefined when the given name does not match', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }, {
                    name: 'test3',
                    route: 'testroute3',
                    view: 'testview3'
                }
            ]);

            // act
            let result = onboarding.getStepByName('notExisting');

            // assert
            assert.isUndefined(result);
        });
    });

    describe('#getProgression', () => {
        it('should return expected total', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }, {
                    name: 'test3',
                    route: 'testroute3',
                    view: 'testview3'
                }
            ]);

            let step = onboarding.getStepByName('test');

            // act
            let result = onboarding.getProgression(step);

            // assert
            assert.equal(3, result.total);
        });

        it('should return first step as current', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }, {
                    name: 'test3',
                    route: 'testroute3',
                    view: 'testview3'
                }
            ]);

            let step = onboarding.getStepByName('test');

            // act
            onboarding.goToStep(step);
            let result = onboarding.getProgression(step);

            // assert
            assert.equal(1, result.current);
        });

        it('should return expected current', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }, {
                    name: 'test3',
                    route: 'testroute3',
                    view: 'testview3'
                }
            ]);

            let step = onboarding.getStepByName('test2');

            // act
            onboarding.goToStep(step);
            let result = onboarding.getProgression(step);


            // assert
            assert.equal(2, result.current);
        });

        it('should return last step as current', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }, {
                    name: 'test3',
                    route: 'testroute3',
                    view: 'testview3'
                }
            ]);

            let step = onboarding.getStepByName('test3');

            // act
            onboarding.goToStep(step);
            let result = onboarding.getProgression(step);


            // assert
            assert.equal(3, result.current);
        });

        it('should return expected labels', () => {
            // arrange
            let onboarding = new Onboarding(null, [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }, {
                    name: 'test3',
                    route: 'testroute3',
                    view: 'testview3'
                }
            ]);
            let step = onboarding.getStepByName('test');
            let expectedLabels = ['test', 'test2', 'test3'];

            // act
            let result = onboarding.getProgression(step);

            // assert
            assert.deepEqual(expectedLabels, result.labels);
        });
    });
});

describe('Onboarding.Step', () => {
    describe('#constructor', () => {
        it('should map expected properties', () => {
            // arrange
            let options = {
                name: 'test',
                route: 'testroute',
                view: 'testview'
            };

            // act
            let result = new Step(options);

            // assert
            assert.isDefined(result.name);
            assert.isDefined(result.route);
            assert.isDefined(result.view);

            assert.equal(result.name, options.name);
            assert.equal(result.route, options.route);
            assert.equal(result.view, options.view);
        });

        it('should not map unexpected properties', () => {
            // arrange
            let options = {
                inject: 'inject'
            };

            // act
            let result = new Step(options);

            // assert
            assert.isUndefined(result.inject);
        });

        it('should override default isActive with new one', () => {
            // arrange
            let overridingIsActive = (user) => {};
            let options = {
                isActive: overridingIsActive
            };

            // act
            let step = new Step(options);

            // assert
            assert.equal(overridingIsActive, step.isActive);
        });
    });

    describe('#isActive', () => {
        it('should return true by default', () => {
            // arrange
            let step = new Step();

            // act
            let result = step.isActive();

            // assert
            assert.isTrue(result);
        });

        it('should call overriding method', () => {
            // arrange
            let spy = sinon.spy();
            let step = new Step({
                isActive: spy
            });

            // act
            let result = step.isActive();

            // assert
            assert(spy.calledOnce);
        });

        it('should not call overriding method on other steps', () => {
            // arrange
            let spy = sinon.spy();
            let step = new Step({
                isActive: spy
            });

            let step2 = new Step();

            // act
            let result = step.isActive();
            let result2 = step2.isActive();

            // assert
            assert(spy.calledOnce);
            assert.isTrue(result2);
        });
    });

    describe('#onValidated', () => {
        it('should add given callback to step changed handlers', () => {
            // arrange
            let step = new Step();
            let callback = () => {};

            // act
            step.onValidated(callback);

            // assert
            assert.include(step.validatedHandlers, callback);
        });

        it('should throw an error when callback is not a function', () => {
            // arrange
            let step = new Step();
            let callback = 'I am a string';
            let fn = () => {
                // act
                step.onValidated(callback);
            }

            // assert
            assert.throws(fn, 'Callback parameter should be a function')
        });
    });

    describe('#triggerValidated', () => {
        it('should not throw an error when validatedHandlers is empty', () => {
            // arrange
            let step = new Step();

            let fn = () => {
                // act
                step.triggerValidated();
            }

            // assert
            assert.doesNotThrow(fn);
        });

        it('should call callback list', () => {
            // arrange
            let step = new Step();

            let callback1 = sinon.spy();
            let callback2 = sinon.spy();

            step.onValidated(callback1);
            step.onValidated(callback2);

            // act
            step.triggerValidated();

            // assert
            assert(callback1.calledOnce);
            assert(callback2.calledOnce);
            assert(callback1.calledWith(step));
            assert(callback2.calledWith(step));
        });
    });

    describe('#submit', () => {
        it('should call triggerValidated', () => {
            // arrange
            let step = new Step();
            step.triggerValidated = sinon.spy();

            // act
            step.submit();

            // assert
            assert(step.triggerValidated.calledOnce);
        });
    });
});
