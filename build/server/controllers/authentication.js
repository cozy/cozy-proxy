// Generated by CoffeeScript 1.10.0
var Authentication, Instance, User, async, getEnv, helpers, localization, otpManager, passport, passwordKeys, randomstring, request,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

passport = require('passport');

randomstring = require('randomstring');

request = require('request-json');

async = require('async');

User = require('../models/user');

Instance = require('../models/instance');

helpers = require('../lib/helpers');

localization = require('../lib/localization_manager');

passwordKeys = require('../lib/password_keys');

otpManager = require('../lib/2fa_manager');

Authentication = require('../middlewares/authentication');

getEnv = function(callback) {
  return User.getUsername(function(err, username) {
    if (err) {
      return callback(err);
    }
    return otpManager.getAuthType(function(err, otp) {
      var env;
      if (err) {
        return callback(err);
      }
      env = {
        public_name: username,
        otp: !!otp,
        apps: Object.keys(require('../lib/router').getRoutes()),
        myAccountsUrl: process.env.COZY_MYACCOUNTS_URL || '/apps/konnectors/'
      };
      return callback(null, env);
    });
  });
};

module.exports.onboarding = function(req, res, next) {
  return getEnv(function(err, env) {
    var error;
    if (err) {
      error = new Error("[Error to access cozy user] " + err.code);
      error.status = 500;
      error.template = {
        name: 'error'
      };
      return next(error);
    } else {
      return User.first(function(err, userData) {
        var hasValidInfos;
        if (err) {
          error = new Error("[Error to access cozy user] " + err.code);
          error.status = 500;
          error.template = {
            name: 'error'
          };
          next(error);
        }
        if (!req.isAuthenticated() && User.isAuthenticatable(userData) && !User.isRegistered(userData)) {
          return res.redirect('/login?next=/register');
        } else if (User.isRegistered(userData)) {
          return res.redirect('/login');
        } else {
          if (userData) {
            hasValidInfos = User.checkInfos(userData);
            env.hasValidInfos = hasValidInfos;
          }
          if (process.env.HIDE_STATS_AGREEMENT) {
            env.HIDE_STATS_AGREEMENT = true;
          }
          localization.setLocale(req.headers['accept-language']);
          env.onboardedSteps = userData != null ? userData.onboardedSteps : void 0;
          return res.render('index', {
            env: env
          });
        }
      });
    }
  });
};

module.exports.disallowAuthenticatedUser = function(req, res, next) {
  if (req.isAuthenticated()) {
    return res.status(403).send({
      error: 'Not allowed to access this enpoint while being authentified'
    });
  } else {
    return next();
  }
};

module.exports.saveUnauthenticatedUser = function(req, res, next) {
  var dataErrors, error, hash, instanceData, passwordValidationError, requestData, userToSave;
  requestData = req.body;
  userToSave = {};
  dataErrors = {};
  if (requestData.password) {
    hash = helpers.cryptPassword(requestData.password);
    userToSave.password = hash.hash;
    userToSave.salt = hash.salt;
    passwordValidationError = User.validatePassword(requestData.password);
    if (Object.keys(passwordValidationError).length) {
      dataErrors.password = passwordValidationError.password;
    }
  }
  ['allow_stats', 'isCGUaccepted', 'onboardedSteps'].forEach((function(_this) {
    return function(property) {
      if (requestData[property] !== void 0 && requestData[property] !== null) {
        return userToSave[property] = requestData[property];
      }
    };
  })(this));
  userToSave.owner = true;
  instanceData = {
    locale: requestData.locale
  };
  if (!Object.keys(dataErrors).length) {
    return User.all(function(err, users) {
      var error, ref;
      if (err) {
        return next(new Error(err));
      }
      if ((ref = users[0]) != null ? ref.password : void 0) {
        error = new Error('Not authorized');
        error.status = 401;
        return next(error);
      } else if (users.length) {
        return users[0].merge(userToSave, function(err) {
          if (err) {
            return next(new Error(err));
          }
          if (next) {
            return next();
          }
          return res.status(200).send({
            result: 'User data correctly updated'
          });
        });
      } else {
        return Instance.createOrUpdate(instanceData, function(err) {
          if (err) {
            return next(new Error(err));
          }
          return User.createNew(userToSave, function(err) {
            if (err) {
              return next(new Error(err));
            }
            localization.setLocale(requestData.locale);
            return res.status(201).send({
              result: 'User data correctly created'
            });
          });
        });
      }
    });
  } else {
    error = new Error('Errors with data');
    error.errors = dataErrors;
    error.status = 400;
    return next(error);
  }
};

module.exports.saveAuthenticatedUser = function(req, res, next) {
  var error, errors, requestData, userToSave, validationErrors;
  requestData = req.body;
  userToSave = {};
  errors = {};
  ['public_name', 'email', 'timezone', 'onboardedSteps'].forEach((function(_this) {
    return function(property) {
      if (requestData[property] != null) {
        return userToSave[property] = requestData[property];
      }
    };
  })(this));
  if (User.isRegistered(userToSave)) {
    userToSave.activated = true;
  }
  validationErrors = User.validate(userToSave);
  if (!Object.keys(validationErrors).length) {
    return User.all(function(err, users) {
      var error;
      if (err) {
        return next(new Error(err));
      }
      if (users.length) {
        return users[0].merge(userToSave, function(err) {
          if (err) {
            return next(new Error(err));
          }
          return res.status(200).send({
            result: 'User data correctly updated'
          });
        });
      } else {
        error = new Error('User document not found');
        error.status = 404;
        return next(error);
      }
    });
  } else {
    error = new Error('Errors with validation');
    error.errors = validationErrors;
    error.status = 400;
    return next(error);
  }
};

module.exports.user = function(req, res, next) {
  var error;
  if (req.isAuthenticated()) {
    return User.first(function(err, userData) {
      var allowedProperties, error, fields, ref, userInfos;
      if (err) {
        error = new Error("[Error to access cozy user] " + err.code);
        error.status = 500;
        error.template = {
          name: 'error'
        };
        return next(error);
      } else {
        allowedProperties = ['public_name', 'email', 'timezone'];
        fields = (ref = req.query.fields) != null ? ref.split(',') : void 0;
        userInfos = (fields != null ? fields.reduce(function(data, property) {
          if (indexOf.call(allowedProperties, property) >= 0) {
            data[property] = userData[property] || null;
          }
          return data;
        }, {}) : void 0) || {};
        return res.status(200).send(userInfos);
      }
    });
  } else {
    error = new Error('Forbidden');
    error.status = 403;
    return next(error);
  }
};

module.exports.loginIndex = function(req, res, next) {
  return getEnv(function(err, env) {
    if (err) {
      return next(new Error(err));
    } else {
      return User.first(function(err, userData) {
        var error;
        if (err) {
          error = new Error("[Error to access cozy user] " + err.code);
          error.status = 500;
          error.template = {
            name: 'error'
          };
          next(error);
        }
        if (!User.isRegistered(userData)) {
          if (!User.isAuthenticatable(userData)) {
            return res.redirect('/register');
          } else if (req.url !== '/login?next=/register') {
            return res.redirect('/login?next=/register');
          }
        }
        res.set('X-Cozy-Login-Page', 'true');
        return res.render('index', {
          env: env
        });
      });
    }
  });
};

module.exports.forgotPassword = function(req, res, next) {
  return User.first(function(err, user) {
    var key;
    if (err) {
      return next(new Error(err));
    } else if (!user) {
      err = new Error('No user registered.');
      err.status = 400;
      err.headers = {
        'Location': '/register/'
      };
      return next(err);
    } else {
      key = randomstring.generate();
      Instance.setResetKey(key);
      return Instance.first(function(err, instance) {
        if (err) {
          return next(err);
        }
        if (instance == null) {
          instance = {
            domain: 'domain.not.set'
          };
        }
        return helpers.sendResetEmail(instance, user, key, function(err, result) {
          if (err) {
            return next(new Error('Email cannot be sent'));
          }
          return res.sendStatus(204);
        });
      });
    }
  });
};

module.exports.resetPasswordIndex = function(req, res, next) {
  return getEnv(function(err, env) {
    if (err) {
      return next(new Error(err));
    } else {
      if (Instance.getResetKey() === req.params.key) {
        return res.render('index', {
          env: env
        });
      } else {
        return res.redirect('/');
      }
    }
  });
};

module.exports.resetPassword = function(req, res, next) {
  var key, newPassword;
  key = req.params.key;
  newPassword = req.body.password;
  return User.first(function(err, user) {
    var data, error, validationErrors;
    if (err != null) {
      return next(new Error(err));
    } else if (user == null) {
      err = new Error('reset error no user');
      err.status = 400;
      err.headers = {
        'Location': '/register/'
      };
      return next(err);
    } else {
      if (Instance.getResetKey() === req.params.key) {
        validationErrors = User.validatePassword(newPassword);
        if (!Object.keys(validationErrors).length) {
          data = {
            password: helpers.cryptPassword(newPassword).hash
          };
          return user.merge(data, function(err) {
            if (err != null) {
              return next(new Error(err));
            } else {
              Instance.resetKey = null;
              return passwordKeys.resetKeys(newPassword, function(err) {
                if (err != null) {
                  return next(new Error(err));
                } else {
                  passport.currentUser = null;
                  return res.sendStatus(204);
                }
              });
            }
          });
        } else {
          error = new Error('Errors in validation');
          error.errors = validationErrors;
          error.status = 400;
          return next(error);
        }
      } else {
        error = new Error('reset error invalid key');
        error.status = 400;
        return next(error);
      }
    }
  });
};

module.exports.logout = function(req, res) {
  req.logout();
  return res.sendStatus(204);
};

module.exports.authenticated = function(req, res) {
  return res.status(200).send({
    isAuthenticated: req.isAuthenticated()
  });
};
