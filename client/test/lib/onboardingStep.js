'use strict';
let assert = require('chai').assert;
let sinon = require('sinon');

let Step = require('../../app/lib/onboarding.coffee').Step;

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
            let step = new Step({ isActive: spy });

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

    describe('#onCompleted', () => {
        it('should add given callback to step changed handlers', () => {
            // arrange
            let step = new Step();
            let callback = () => {};

            // act
            step.onCompleted(callback);

            // assert
            assert.include(step.completedHandlers, callback);
        });

        it('should throw an error when callback is not a function', () => {
            // arrange
            let step = new Step();
            let callback = 'I am a string';
            let fn = () => {
                // act
                step.onCompleted(callback);
            }

            // assert
            assert.throws(fn, 'Callback parameter should be a function')
        });
    });

    describe('#triggerCompleted', () => {
        it('should not throw an error when completedHandlers is empty', () => {
            // arrange
            let step = new Step();

            let fn = () => {
                // act
                step.triggerCompleted();
            }

            // assert
            assert.doesNotThrow(fn);
        });

        it('should call callback list', () => {
            // arrange
            let step = new Step();

            let callback1 = sinon.spy();
            let callback2 = sinon.spy();

            step.onCompleted(callback1);
            step.onCompleted(callback2);

            // act
            step.triggerCompleted();

            // assert
            assert(callback1.calledOnce);
            assert(callback2.calledOnce);
            assert(callback1.calledWith(step));
            assert(callback2.calledWith(step));
        });
    });


    describe('#submit', () => {
        it('should call save', () => {
            // arrange
            let step = new Step();
            let savePromise = Promise.resolve();
            let promiseStub = sinon.stub(step, 'save');
            promiseStub.returns(savePromise);

            // act
            step.submit();

            // assert
            assert(step.save.calledOnce);
        });
    });

    describe('#fetchUser', () => {
        it('should fetch username by default', () => {
            // arrange
            let username = 'Claude';

            // act
            let step = new Step({}, {username: username});

            // assert
            assert.equal(username, step.username);
        });

        it('should call overriding method', () => {
            // arrange
            let spy = sinon.spy();

            // act
            // fetchUser is called in constructor
            let step = new Step({
                fetchUser: spy
            });

            // assert
            assert(spy.calledOnce);
        });

        it('should not call overriding method on other steps', () => {
            // arrange
            let spy = sinon.spy();

            // act
            let step = new Step({
                fetchUser: spy
            });

            let step2 = new Step();

            // assert
            assert(spy.calledOnce);
        });
    });
});
