'use strict';
let assert = require('chai').assert;
let sinon = require('sinon');

let Onboarding = require('../../app/lib/onboarding/index.coffee');

describe('OnboardingState', () => {
    let user;
    let steps;
    let state;
    let actions;

    beforeEach(() => {
        user = null;
        steps = [
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
        ];
        actions = { 'change': sinon.spy() }

        // arrange
        let onboarding = new Onboarding({ user, steps, actions });
        state = onboarding.state
    })


    describe('.getCurrent()', () =>
        it('should return step[0]', () => {
            assert.deepEqual(steps[0], state.getCurrent())
        }
    });

    describe('.getNext()', () => {
        it('should return step[1]', () => {
            assert.deepEqual(steps[1], state.getNext())
        }
    });

    describe('.getPrevious()', () => {
        it.skip('should throw an error', () => {
            // assert.deepEqual(undefined, state.getPrevious())
        }
        it.skip('should return step[0]', () => {
            // assert.deepEqual(undefined, state.getPrevious())
        }
    });

    describe('.getIndexOfStep(name)', () => {
        it('should return 0', () => {
            assert.equal(0, state.getIndexOfStep('test1'));
        }
        it('should return 1', () => {
            assert.equal(1, state.getIndexOfStep('test2'));
        }
        it('should return 2', () => {
            assert.equal(2, state.getIndexOfStep('test3'));
        }
    });


    describe.skip('.save()', () => {
        it('should savec `previous` and `current` value', () => {
        });

        it('should call `actions.change` callback', () => {
        });

        it('should not trigger `change` when update with the same step', () => {

        });
    });


    describe('.getIndexOfStep(name)', () => {
        let user;
        let steps;
        let onboarding;

        beforeEach(() => {
            user = null;
            steps = [
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
            ];

            // arrange
            onboarding = new Onboarding({ user, steps });
        });


        it('should retrieve `step` by its name', () => {
            let result = onboarding.getIndexOfStep(steps[1].name);

            assert.equal(steps[1], result);
        });


        it.skip('should throw error when step isnt found', () => {
            // let result = onboarding.getIndexOfStep('notExisting');
            //
            // assert.isUndefined(result);
        });
    });
}


describe('Onboarding', () => {

    describe('.initialize()', () => {

        it('should set `user` property', () => {
            // arrange
            let user = {
                name: 'Claude',
                lastname: 'Causi'
            };

            // act
            let onboarding = new Onboarding({user, steps: []});

            // assert
            assert.deepEqual(onboarding.user, user);
        });

        it('should set `actions` property', () => {
            // arrange
            let actions = { 'change': function() {} };

            // act
            let onboarding = new Onboarding({ actions });

            // assert
            assert.deepEqual(actions, onboarding.actions);
        });

        it('should select first `step` as default', () => {
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
            let onboarding = new Onboarding({user, steps});

            // assert
            assert.isDeepEqual(steps[0], onboarding.getState());
            assert.isDeepEqual(steps, onboarding.getAllSteps());
        });

        it('should not map unexpected steps properties', () => {
            // arrange
            let user = null;
            let steps = [{
                name: 'test',
                route: 'testroute',
                view: 'testview',
                unexpected: 'do not map'
            }];

            // act
            let onboarding = new Onboarding({user, steps});

            // assert
            let step = onboarding.getState();
            assert.equal('test', step.name);
            assert.equal('testroute', step.route);
            assert.equal('testview', step.view);
            assert.isUndefined(step.unexpected);
        });

        it('should throw error when `steps` parameter is missing', () => {
            let fn = () => {
                let onboarding = new Onboarding();
            }
            assert.throw(fn, 'Missing mandatory `steps` parameter');
        });
    });


    describe.skip('.getStepView(name)', () => {});


    describe.skip('.getState()', () => {});


    describe.skip('.getAllSteps()', () => {});


    describe('.doSelectStep(name)', () => {
        let user;
        let steps;
        let onboarding;
        let actions;

        beforeEach(() => {
            user = null;
            steps = [
                {
                    name: 'test',
                    route: 'testroute',
                    view: 'testview'
                }, {
                    name: 'test2',
                    route: 'testroute2',
                    view: 'testview2'
                }
            ];
            actions = { 'change': sinon.spy() }

            // arrange
            onboarding = new Onboarding({ user, steps, actions });
        })

        it('should select step called in parameter', () => {
            // Goto next step
            onboarding.doSelectStep('test2');

            // assert
            const previousStep = steps[0];
            const currentStep = steps[1];
            assert(actions['change'].calledOnce);
            assert(actions['change'].withArgs(currentStep, previousStep));
        });
    });

    describe.skip('.doValidate(data)', () => {});

    describe('.doSubmit(data)', () => {
        let user;
        let steps;
        let onboarding;
        let actions;

        beforeEach(() => {
            user = null;
            steps = [
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
            ];
            actions = { 'change': sinon.spy() }

            // arrange
            onboarding = new Onboarding({ user, steps, actions });
        })


        it('should update step with given value', () => {
            onboarding.doSubmit(steps[1]);
            assert.equal(steps[1], onboarding.getState());

            onboarding.doSubmit(steps[0]);
            assert.equal(steps[0], onboarding.getState());
        });


        it('should trigger `change`', () => {
            // Select 2nd step
            onboarding.doSubmit(steps[1]);
            let previousStep = steps[0];
            let currentStep = steps[1];
            assert.equal(1, actions['change'].callCount);
            assert(actions['change'].withArgs(currentStep, previousStep));

            // Then go back to 1rst step
            onboarding.doSubmit(steps[0]);
            previousStep = steps[1];
            currentStep = steps[0];
            assert.equal(2, actions['change'].callCount);
            assert(actions['change'].withArgs(currentStep, previousStep));

            // and go to last step
            onboarding.doSubmit(steps[2]);
            previousStep = steps[0];
            currentStep = steps[2];
            assert.equal(3, actions['change'].callCount);
            assert(actions['change'].withArgs(currentStep, previousStep));
        });
    });
});
