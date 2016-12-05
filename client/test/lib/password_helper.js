'use strict';
let assert = require('chai').assert;
let passwordHelper = require('../../app/lib/password_helper.coffee');


describe('PasswordHelper', () => {

  describe('#getStrength', () => {

    it('should return 1% and weak label for empty password', () => {
      // arrange
      let password = '';

      // act
      let strength = passwordHelper.getStrength(password);

      // assert
      assert.equal(strength.percentage, 1);
      assert.equal(strength.label, 'weak');
    });


    it('should be under 33% and "weak" label for "Azerty"', () => {
      // arrange
      let password = 'Azerty';

      // act
      let strength = passwordHelper.getStrength(password);

      // assert
      assert.isBelow(strength.percentage, 33);
      assert.equal(strength.label, 'weak');
    });


    it('should be between 33% and 66% "moderate" label for "Azerty1aze$"', () => {
      // arrange
      let password = 'Azerty1aze$';

      // act
      let strength = passwordHelper.getStrength(password);

      // assert
      assert.isAbove(strength.percentage, 33);
      assert.isBelow(strength.percentage, 66);
      assert.equal(strength.label, 'moderate');
    });


    it('should be above 66% and "strong" label for "Azerty1aze$uiopqs9LT"', () => {
      // arrange
      let password = 'Azerty1aze$uiopqs9LT';

      // act
      let strength = passwordHelper.getStrength(password);

      // assert
      assert.isAbove(strength.percentage, 66);
      assert.equal(strength.label, 'strong');
    });


    it('should throw error if no password', () => {
      // arrange
      let fn = () => {
          // act
          let strength = passwordHelper.getStrength();
      }

      // assert
      assert.throw(fn, 'password parameter is missing');

    });
  });
});
