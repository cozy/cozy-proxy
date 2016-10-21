'use strict';
let assert = require('chai').assert;

let passwordHelper = require('../../app/lib/password_helper.coffee');

describe('PasswordHelper', () => {

  describe('#getStrength', () => {

    it('should return 0% and weak label for empty password', () => {
      // arrange
      let password = '';

      // act
      let strength = passwordHelper.getStrength(password);

      // assert
      assert.equal(strength.percentage, 0);
      assert.equal(strength.label, 'weak');
    });

    it('should return ~20% and "weak" label for "password"', () => {
      // arrange
      let password = 'password';

      // act
      let strength = passwordHelper.getStrength(password);

      // assert
      assert.equal(strength.percentage, 20.109375000000004);
      assert.equal(strength.label, 'weak');
    });


    it('should return ~53% and "moderate" label for "PassworD"', () => {
      // arrange
      let password = 'PassworD';

      // act
      let strength = passwordHelper.getStrength(password);

      // assert
      assert.equal(strength.percentage, 53.62500000000001);
      assert.equal(strength.label, 'moderate');
    });

    it('should return ~83% and "strong" label for "P&33w0rrrD$"', () => {
      // arrange
      let password = 'P&33w0rrrD$';

      // act
      let strength = passwordHelper.getStrength(password);

      // assert
      assert.equal(strength.percentage, 83.78310951387205);
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
