'use strict';
let assert = require('chai').assert;
let sinon = require('sinon');
let fetchMock = require('fetch-mock');


describe('Step: infos', () => {

    let jsdom;
    let infos;

    before(function () {
        jsdom = require('jsdom-global')();
        infos = require('../../../app/config/steps/infos.coffee');
    });

    after(function () {
        jsdom();
    });

    describe('#isActive', () => {
        it('should return true for user.hasValidInfos is false', () => {
            // arrange
            let user = {
                hasValidInfos: false
            };

            // act
            let result = infos.isActive(user);

            // assert
            assert.isTrue(result);
        });

        it('should return false for user.hasValidInfos is true', () => {
            // arrange
            let user = {
                hasValidInfos: true
            };

            // act
            let result = infos.isActive(user);

            // assert
            assert.isFalse(result);
        });
    });

    describe('#getData', () => {
        afterEach(() =>{
            delete infos.publicName;
            delete infos.email;
            delete infos.timezone;
        });

        it('should return email value', () => {
            // arrange
            const expectedEmail = 'claude@causi.cc';
            infos.email = expectedEmail;

            // act
            let data = infos.getData();

            // assert
            assert.equal(data.email, expectedEmail);
        });

        it('should return public_name value', () => {
            // arrange
            const expectedPublicName = 'Claude Causi';
            infos.publicName = expectedPublicName;

            // act
            let data = infos.getData();

            // assert
            assert.equal(data.public_name, expectedPublicName);
        });

        it('should return timezone value', () => {
            // arrange
            const expectedTimezone = 'Europe/London';
            infos.timezone = expectedTimezone;

            // act
            let data = infos.getData();

            // assert
            assert.equal(data.timezone, expectedTimezone);
        });

        it('should return undefined values when data have not been set', () => {
            // arrange

            // act
            let data = infos.getData();

            // assert
            assert.isUndefined(data.public_name);
            assert.isUndefined(data.email);
            assert.isUndefined(data.timezone);
        });
    });

    describe('#validate', () => {
        it('should not validate empty public_name', () => {
            // arrange
            const data = {
                public_name: ''
            };

            const expectedMessage = 'missing public_name';

            // act
            let validation = infos.validate(data);

            // assert
            assert.isFalse(validation.success);
            assert.isDefined(validation.errors);
            assert.isDefined(validation.errors['public_name']);
            assert.equal(validation.errors['public_name'], expectedMessage);
        });

        it('should not validate empty email', () => {
            // arrange
            const data = {
                email: ''
            };

            const expectedMessage = 'missing email';

            // act
            let validation = infos.validate(data);

            // assert
            assert.isFalse(validation.success);
            assert.isDefined(validation.errors);
            assert.isDefined(validation.errors['email']);
            assert.equal(validation.errors['email'], expectedMessage);
        });

        it('should not validate empty timezone', () => {
            // arrange
            const data = {
                timezone: ''
            };

            const expectedMessage = 'missing timezone';

            // act
            let validation = infos.validate(data);

            // assert
            assert.isFalse(validation.success);
            assert.isDefined(validation.errors);
            assert.isDefined(validation.errors['timezone']);
            assert.equal(validation.errors['timezone'], expectedMessage);
        });

        it('should validate valid public_name', () => {
            // arrange
            const data = {
                public_name: 'Claude Causi'
            };

            // act
            let validation = infos.validate(data);

            // assert
            assert.isUndefined(validation.errors['public_name']);
        });

        it('should validate valid email', () => {
            // arrange
            const data = {
                email: 'claude@causi.cc'
            };

            // act
            let validation = infos.validate(data);

            // assert
            assert.isUndefined(validation.errors['email']);
        });

        it('should validate valid timezone', () => {
            // arrange
            const data = {
                timezone: 'Africa/Abidjan'
            };

            // act
            let validation = infos.validate(data);

            // assert
            assert.isUndefined(validation.errors['timezone']);
        });

        it('should not validate invalid email', () => {
            // arrange
            const data = {
                email: 'claude.causi.cc'
            };

            let expectedMessage = 'invalid email format';

            // act
            let validation = infos.validate(data);

            // assert
            assert.isFalse(validation.success);
            assert.isDefined(validation.errors);
            assert.isDefined(validation.errors['email']);
            assert.equal(validation.errors['email'], expectedMessage);
        });

        it('should not validate invalid timzone', () => {
            // arrange
            const data = {
                timezone: 'Fakeland/Nowhere'
            };

            let expectedMessage = 'invalid timezone';

            // act
            let validation = infos.validate(data);

            // assert
            assert.isFalse(validation.success);
            assert.isDefined(validation.errors);
            assert.isDefined(validation.errors['timezone']);
            assert.equal(validation.errors['timezone'], expectedMessage);
        });

        it('should validate all valid data', () => {
            // arrange
            const data = {
                public_name: 'Claude Causi',
                email: 'claude@causi.cc',
                timezone: 'America/Guadeloupe'
            };

            // act
            let validation = infos.validate(data);

            // assert
            assert.isTrue(validation.success);
            assert.equal(validation.errors.length, 0);
        });
    });

    describe('#fetchData', () => {
        afterEach(() =>{
            delete infos.publicName;
            delete infos.email;
            delete infos.timezone;
        });

        it('should make GET request', () => {
            // arrange
            const mockedData = {
                public_name : 'Claude Fetched',
                email: 'claude@fetched.com',
                timezone: 'Network/Fetch'
            };

            const expectedUrl = '/user?fields=public_name,email,timezone';
            fetchMock.get('*', mockedData);

            // act
            infos.fetchData()

            // assert
            assert.ok(fetchMock.called());
            assert.equal(fetchMock.lastUrl(), expectedUrl);
            assert.equal(fetchMock.lastOptions().credentials, 'include');
        });

        it('should map data from GET request', (done) => {
            // arrange
            const mockedData = {
                public_name : 'Claude Fetched',
                email: 'claude@fetched.com',
                timezone: 'Network/Fetch'
            };

            fetchMock.get('*', mockedData);

            // act
            infos.fetchData()

            setTimeout( () => {
                // assert
                assert.equal(infos.publicName, mockedData.public_name);
                assert.equal(infos.email, mockedData.email);
                assert.equal(infos.timezone, mockedData.timezone);
                done();
            }, 5);

        });
    });

    describe('#save', () => {
        it('should send POST request', () => {
            // arrange
            fetchMock.put('*', 200);
            const data = {
                password: 'plop',
                onboardedSteps: [
                    'welcome',
                    'agreement',
                    'password',
                    'infos'
                ]
            };

            const expectedUrl = '/register'

            // act
            infos.save(data);

            // assert
            assert.ok(fetchMock.called());
            assert.equal(fetchMock.lastUrl(), expectedUrl);
            assert.equal(fetchMock.lastOptions().credentials, 'include');
            assert.deepEqual(
                fetchMock.lastOptions().body,
                JSON.stringify(data)
            );
        });

        it('should call `handleSaveSuccess', (done) => {
            // arrange
            fetchMock.put('*', 200);
            const data = {
                password: 'plop',
                onboardedSteps: [
                    'welcome',
                    'agreement',
                    'password',
                    'infos'
                ]
            };

            infos.handleSaveSuccess = sinon.spy();

            // act
            infos.save(data);

            setTimeout( () => {
                // assert
                assert(infos.handleSaveSuccess.calledOnce);
                done();
            });
        });
    });
});
