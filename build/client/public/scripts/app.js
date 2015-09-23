(function() {
  'use strict';

  var globals = typeof window === 'undefined' ? global : window;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};
  var has = ({}).hasOwnProperty;

  var aliases = {};

  var endsWith = function(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
  };

  var unalias = function(alias, loaderPath) {
    var start = 0;
    if (loaderPath) {
      if (loaderPath.indexOf('components/' === 0)) {
        start = 'components/'.length;
      }
      if (loaderPath.indexOf('/', start) > 0) {
        loaderPath = loaderPath.substring(start, loaderPath.indexOf('/', start));
      }
    }
    var result = aliases[alias + '/index.js'] || aliases[loaderPath + '/deps/' + alias + '/index.js'];
    if (result) {
      return 'components/' + result.substring(0, result.length - '.js'.length);
    }
    return alias;
  };

  var expand = (function() {
    var reg = /^\.\.?(\/|$)/;
    return function(root, name) {
      var results = [], parts, part;
      parts = (reg.test(name) ? root + '/' + name : name).split('/');
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part === '..') {
          results.pop();
        } else if (part !== '.' && part !== '') {
          results.push(part);
        }
      }
      return results.join('/');
    };
  })();
  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var absolute = expand(dirname(path), name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var require = function(name, loaderPath) {
    var path = expand(name, '.');
    if (loaderPath == null) loaderPath = '/';
    path = unalias(name, loaderPath);

    if (has.call(cache, path)) return cache[path].exports;
    if (has.call(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has.call(cache, dirIndex)) return cache[dirIndex].exports;
    if (has.call(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '" from '+ '"' + loaderPath + '"');
  };

  require.alias = function(from, to) {
    aliases[to] = from;
  };

  require.register = require.define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has.call(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  require.list = function() {
    var result = [];
    for (var item in modules) {
      if (has.call(modules, item)) {
        result.push(item);
      }
    }
    return result;
  };

  require.brunch = true;
  globals.require = require;
})();
require.register("application", function(exports, require, module) {

/*
application

Main application that create a Mn.Application singleton and exposes it. Needs
router and app_layout view.
 */
var AppLayout, Application, Router,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Router = require('routes');

AppLayout = require('views/app_layout');

Application = (function(_super) {
  __extends(Application, _super);

  function Application() {
    return Application.__super__.constructor.apply(this, arguments);
  }


  /*
  Sets application
  
  We instanciate root application components
  - router: we pass the app reference to it to easily get it without requiring
            application module later.
  - layout: the application layout view, rendered.
   */

  Application.prototype.initialize = function() {
    return this.on('start', (function(_this) {
      return function(options) {
        _this.router = new Router({
          app: _this
        });
        _this.layout = new AppLayout();
        _this.layout.render();
        if (Backbone.history) {
          Backbone.history.start({
            pushState: true
          });
        }
        if (typeof Object.freeze === 'function') {
          return Object.freeze(_this);
        }
      };
    })(this));
  };

  return Application;

})(Backbone.Marionette.Application);

module.exports = new Application();
});

;require.register("initialize", function(exports, require, module) {

/*
Application bootstrap

Sets the browser environment to prepare it to launch the app, and then require
the application.
 */
var application, initLocale;

application = require('./application');


/*
Polyglot initialization

Locales need to be loaded in Polyglot before using it. We need to declares a
global translator `t` method to use it in Marionette templates.

We use the `html[lang]` attribute to get the correct locale.
 */

initLocale = function() {
  var e, locale, phrases, polyglot;
  locale = $('html').attr('lang');
  try {
    phrases = require("locales/" + locale);
  } catch (_error) {
    e = _error;
    phrases = require('locales/en');
  }
  polyglot = new Polyglot({
    phrases: phrases,
    locale: locale
  });
  return window.t = polyglot.t.bind(polyglot);
};


/*
Starts

Trigger locale initilization and starts application singleton.
 */

$(function() {
  initLocale();
  return application.start();
});
});

;require.register("lib/state_model", function(exports, require, module) {

/*
State-Machines top-level class

When building a state-machine (a viewModel object propulsed by Bacon), this
top-level class is used to provides common methods an properties.
 */
var StateModel;

module.exports = StateModel = (function() {
  StateModel.prototype.properties = {};

  StateModel.prototype._cache = {};


  /*
  Initialize
  
  If a hash of key:values is passed at initialization, they're added to the
  state-machine properties as a Bacon.constant property.
   */

  function StateModel(options) {
    var key, value;
    for (key in options) {
      value = options[key];
      this.add(key, Bacon.constant(value));
    }
    this.initialize();
  }

  StateModel.prototype.initialize = function() {};


  /*
  Get property
  
  Returns the property from the `properties` object
   */

  StateModel.prototype.get = function(name) {
    if (this.properties[name]) {
      return this.properties[name];
    } else {
      return Bacon.constant(void 0);
    }
  };


  /*
  Add property
  
  Add a property to the `properties` object. When a new property is added, a
  handler is binded to its changes to updates the internal `_cache` object
  with its new value.
   */

  StateModel.prototype.add = function(name, property) {
    if (!this.properties[name]) {
      this.properties[name] = property;
      property.onValue((function(_this) {
        return function(value) {
          return _this._cache[name] = value;
        };
      })(this));
    }
    return property;
  };


  /*
  `toJSON` simplies returns the `_cache` object to get current properties
  values.
   */

  StateModel.prototype.toJSON = function() {
    return this._cache;
  };

  return StateModel;

})();
});

;require.register("lib/timezones", function(exports, require, module) {

/*
Timezones

Exposes an array of all available timezones.
 */
module.exports = ["Europe/Paris", "Europe/Berlin", "Europe/Madrid", "Europe/Rome", "America/Los_Angeles", "America/New_York", "Africa/Abidjan", "Africa/Accra", "Africa/Addis_Ababa", "Africa/Algiers", "Africa/Asmara", "Africa/Bamako", "Africa/Bangui", "Africa/Banjul", "Africa/Bissau", "Africa/Blantyre", "Africa/Brazzaville", "Africa/Bujumbura", "Africa/Cairo", "Africa/Casablanca", "Africa/Ceuta", "Africa/Conakry", "Africa/Dakar", "Africa/Dar_es_Salaam", "Africa/Djibouti", "Africa/Douala", "Africa/El_Aaiun", "Africa/Freetown", "Africa/Gaborone", "Africa/Harare", "Africa/Johannesburg", "Africa/Kampala", "Africa/Khartoum", "Africa/Kigali", "Africa/Kinshasa", "Africa/Lagos", "Africa/Libreville", "Africa/Lome", "Africa/Luanda", "Africa/Lubumbashi", "Africa/Lusaka", "Africa/Malabo", "Africa/Maputo", "Africa/Maseru", "Africa/Mbabane", "Africa/Mogadishu", "Africa/Monrovia", "Africa/Nairobi", "Africa/Ndjamena", "Africa/Niamey", "Africa/Nouakchott", "Africa/Ouagadougou", "Africa/Porto-Novo", "Africa/Sao_Tome", "Africa/Tripoli", "Africa/Tunis", "Africa/Windhoek", "America/Adak", "America/Anchorage", "America/Anguilla", "America/Antigua", "America/Araguaina", "America/Argentina/Buenos_Aires", "America/Argentina/Catamarca", "America/Argentina/Cordoba", "America/Argentina/Jujuy", "America/Argentina/La_Rioja", "America/Argentina/Mendoza", "America/Argentina/Rio_Gallegos", "America/Argentina/Salta", "America/Argentina/San_Juan", "America/Argentina/San_Luis", "America/Argentina/Tucuman", "America/Argentina/Ushuaia", "America/Aruba", "America/Asuncion", "America/Atikokan", "America/Bahia", "America/Barbados", "America/Belem", "America/Belize", "America/Blanc-Sablon", "America/Boa_Vista", "America/Bogota", "America/Boise", "America/Cambridge_Bay", "America/Campo_Grande", "America/Cancun", "America/Caracas", "America/Cayenne", "America/Cayman", "America/Chicago", "America/Chihuahua", "America/Costa_Rica", "America/Cuiaba", "America/Curacao", "America/Danmarkshavn", "America/Dawson", "America/Dawson_Creek", "America/Denver", "America/Detroit", "America/Dominica", "America/Edmonton", "America/Eirunepe", "America/El_Salvador", "America/Fortaleza", "America/Glace_Bay", "America/Godthab", "America/Goose_Bay", "America/Grand_Turk", "America/Grenada", "America/Guadeloupe", "America/Guatemala", "America/Guayaquil", "America/Guyana", "America/Halifax", "America/Havana", "America/Hermosillo", "America/Indiana/Indianapolis", "America/Indiana/Knox", "America/Indiana/Marengo", "America/Indiana/Petersburg", "America/Indiana/Tell_City", "America/Indiana/Vevay", "America/Indiana/Vincennes", "America/Indiana/Winamac", "America/Inuvik", "America/Iqaluit", "America/Jamaica", "America/Juneau", "America/Kentucky/Louisville", "America/Kentucky/Monticello", "America/La_Paz", "America/Lima", "America/Los_Angeles", "America/Maceio", "America/Managua", "America/Manaus", "America/Martinique", "America/Matamoros", "America/Mazatlan", "America/Menominee", "America/Merida", "America/Mexico_City", "America/Miquelon", "America/Moncton", "America/Monterrey", "America/Montevideo", "America/Montreal", "America/Montserrat", "America/Nassau", "America/New_York", "America/Nipigon", "America/Nome", "America/Noronha", "America/North_Dakota/Center", "America/North_Dakota/New_Salem", "America/Ojinaga", "America/Panama", "America/Pangnirtung", "America/Paramaribo", "America/Phoenix", "America/Port-au-Prince", "America/Port_of_Spain", "America/Porto_Velho", "America/Puerto_Rico", "America/Rainy_River", "America/Rankin_Inlet", "America/Recife", "America/Regina", "America/Resolute", "America/Rio_Branco", "America/Santa_Isabel", "America/Santarem", "America/Santiago", "America/Santo_Domingo", "America/Sao_Paulo", "America/Scoresbysund", "America/St_Johns", "America/St_Kitts", "America/St_Lucia", "America/St_Thomas", "America/St_Vincent", "America/Swift_Current", "America/Tegucigalpa", "America/Thule", "America/Thunder_Bay", "America/Tijuana", "America/Toronto", "America/Tortola", "America/Vancouver", "America/Whitehorse", "America/Winnipeg", "America/Yakutat", "America/Yellowknife", "Antarctica/Casey", "Antarctica/Davis", "Antarctica/DumontDUrville", "Antarctica/Mawson", "Antarctica/McMurdo", "Antarctica/Palmer", "Antarctica/Rothera", "Antarctica/Syowa", "Antarctica/Vostok", "Asia/Aden", "Asia/Almaty", "Asia/Amman", "Asia/Anadyr", "Asia/Aqtau", "Asia/Aqtobe", "Asia/Ashgabat", "Asia/Baghdad", "Asia/Bahrain", "Asia/Baku", "Asia/Bangkok", "Asia/Beirut", "Asia/Bishkek", "Asia/Brunei", "Asia/Choibalsan", "Asia/Chongqing", "Asia/Colombo", "Asia/Damascus", "Asia/Dhaka", "Asia/Dili", "Asia/Dubai", "Asia/Dushanbe", "Asia/Gaza", "Asia/Harbin", "Asia/Ho_Chi_Minh", "Asia/Hong_Kong", "Asia/Hovd", "Asia/Irkutsk", "Asia/Jakarta", "Asia/Jayapura", "Asia/Jerusalem", "Asia/Kabul", "Asia/Kamchatka", "Asia/Karachi", "Asia/Kashgar", "Asia/Kathmandu", "Asia/Kolkata", "Asia/Krasnoyarsk", "Asia/Kuala_Lumpur", "Asia/Kuching", "Asia/Kuwait", "Asia/Macau", "Asia/Magadan", "Asia/Makassar", "Asia/Manila", "Asia/Muscat", "Asia/Nicosia", "Asia/Novokuznetsk", "Asia/Novosibirsk", "Asia/Omsk", "Asia/Oral", "Asia/Phnom_Penh", "Asia/Pontianak", "Asia/Pyongyang", "Asia/Qatar", "Asia/Qyzylorda", "Asia/Rangoon", "Asia/Riyadh", "Asia/Sakhalin", "Asia/Samarkand", "Asia/Seoul", "Asia/Shanghai", "Asia/Singapore", "Asia/Taipei", "Asia/Tashkent", "Asia/Tbilisi", "Asia/Tehran", "Asia/Thimphu", "Asia/Tokyo", "Asia/Ulaanbaatar", "Asia/Urumqi", "Asia/Vientiane", "Asia/Vladivostok", "Asia/Yakutsk", "Asia/Yekaterinburg", "Asia/Yerevan", "Atlantic/Azores", "Atlantic/Bermuda", "Atlantic/Canary", "Atlantic/Cape_Verde", "Atlantic/Faroe", "Atlantic/Madeira", "Atlantic/Reykjavik", "Atlantic/South_Georgia", "Atlantic/St_Helena", "Atlantic/Stanley", "Australia/Adelaide", "Australia/Brisbane", "Australia/Broken_Hill", "Australia/Currie", "Australia/Darwin", "Australia/Eucla", "Australia/Hobart", "Australia/Lindeman", "Australia/Lord_Howe", "Australia/Melbourne", "Australia/Perth", "Australia/Sydney", "Canada/Atlantic", "Canada/Central", "Canada/Eastern", "Canada/Mountain", "Canada/Newfoundland", "Canada/Pacific", "Europe/Amsterdam", "Europe/Andorra", "Europe/Athens", "Europe/Belgrade", "Europe/Berlin", "Europe/Brussels", "Europe/Bucharest", "Europe/Budapest", "Europe/Chisinau", "Europe/Copenhagen", "Europe/Dublin", "Europe/Gibraltar", "Europe/Helsinki", "Europe/Istanbul", "Europe/Kaliningrad", "Europe/Kiev", "Europe/Lisbon", "Europe/London", "Europe/Luxembourg", "Europe/Madrid", "Europe/Malta", "Europe/Minsk", "Europe/Monaco", "Europe/Moscow", "Europe/Oslo", "Europe/Paris", "Europe/Prague", "Europe/Riga", "Europe/Rome", "Europe/Samara", "Europe/Simferopol", "Europe/Sofia", "Europe/Stockholm", "Europe/Tallinn", "Europe/Tirane", "Europe/Uzhgorod", "Europe/Vaduz", "Europe/Vienna", "Europe/Vilnius", "Europe/Volgograd", "Europe/Warsaw", "Europe/Zaporozhye", "Europe/Zurich", "GMT", "Indian/Antananarivo", "Indian/Chagos", "Indian/Christmas", "Indian/Cocos", "Indian/Comoro", "Indian/Kerguelen", "Indian/Mahe", "Indian/Maldives", "Indian/Mauritius", "Indian/Mayotte", "Indian/Reunion", "Pacific/Apia", "Pacific/Auckland", "Pacific/Chatham", "Pacific/Easter", "Pacific/Efate", "Pacific/Enderbury", "Pacific/Fakaofo", "Pacific/Fiji", "Pacific/Funafuti", "Pacific/Galapagos", "Pacific/Gambier", "Pacific/Guadalcanal", "Pacific/Guam", "Pacific/Honolulu", "Pacific/Johnston", "Pacific/Kiritimati", "Pacific/Kosrae", "Pacific/Kwajalein", "Pacific/Majuro", "Pacific/Marquesas", "Pacific/Midway", "Pacific/Nauru", "Pacific/Niue", "Pacific/Norfolk", "Pacific/Noumea", "Pacific/Pago_Pago", "Pacific/Palau", "Pacific/Pitcairn", "Pacific/Ponape", "Pacific/Port_Moresby", "Pacific/Rarotonga", "Pacific/Saipan", "Pacific/Tahiti", "Pacific/Tarawa", "Pacific/Tongatapu", "Pacific/Truk", "Pacific/Wake", "Pacific/Wallis", "US/Alaska", "US/Arizona", "US/Central", "US/Eastern", "US/Hawaii", "US/Mountain", "US/Pacific", "UTC"];
});

;require.register("routes/index", function(exports, require, module) {

/*
Main application Router

Handles routes exposed by the application. It generate views/viewModels couples
when needed and show them in the app_layout regions.
 */
var AuthModel, AuthView, RegisterView, RegistrationModel, Router,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

RegisterView = require('views/register');

RegistrationModel = require('states/registration');

AuthView = require('views/auth');

AuthModel = require('states/auth');

module.exports = Router = (function(_super) {
  __extends(Router, _super);

  function Router() {
    return Router.__super__.constructor.apply(this, arguments);
  }

  Router.prototype.routes = {
    'login(?next=*path)': 'login',
    'login(/*path)': 'login',
    'password/reset/:key': 'resetPassword',
    'register(?step=:step)': 'register'
  };


  /*
  Initialize stores the application reference for a later use inside the
  router.
   */

  Router.prototype.initialize = function(options) {
    return this.app = options.app;
  };


  /*
  Auth view generation
  
  Login and ResetPassword views are basically the same ones and uses the same
  logics. So they use the same view/state-model class and we switch the
  rendering mode at launch by passing a `type` option.
  
  View options also contains a `backend` url which is the endpoint called by
  the submitted form.
   */

  Router.prototype.auth = function(path, options) {
    var auth;
    auth = new AuthModel({
      next: path
    });
    return this.app.layout.showChildView('content', new AuthView(_.extend(options, {
      model: auth
    })));
  };


  /*
  login route
  
  `path` will be extracted from url:
  - the part after the `/login` (e.g. /login/foo/bar => /foo/bar)
  - a `next` query string parameter (the new and more cleaner way, see
  server/middlewares/authentication.coffee#L36)
   */

  Router.prototype.login = function(path) {
    if (path == null) {
      path = '/';
    }
    if (window.location.hash) {
      path = window.location.hash;
    }
    return this.auth(path, {
      backend: '/login',
      type: 'login'
    });
  };

  Router.prototype.resetPassword = function(key) {
    return this.auth('/login', {
      backend: window.location.pathname,
      type: 'reset'
    });
  };


  /*
  Register route
  
  Register views uses the same layout view and the step content is a subview
  component determined by the step param.
   */

  Router.prototype.register = function(step) {
    var currentView, registration;
    if (step == null) {
      step = 'preset';
    }
    currentView = this.app.layout.getChildView('content');
    if (!((currentView != null) && currentView instanceof RegisterView)) {
      registration = new RegistrationModel();
      registration.get('step').map(function(step) {
        if (step) {
          return "register?step=" + step;
        }
      }).assign(this, 'navigate');
      currentView = new RegisterView({
        model: registration
      });
      this.app.layout.showChildView('content', currentView);
    }
    return currentView.model.setStep(step);
  };

  return Router;

})(Backbone.Router);
});

;require.register("states/auth", function(exports, require, module) {

/*
Auth state-machine

Exposed streams and properties used by the Login and ResetPassword views.
 */
var Auth, StateModel,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

StateModel = require('lib/state_model');

module.exports = Auth = (function(_super) {
  __extends(Auth, _super);

  function Auth() {
    this.sendResetSubmit = __bind(this.sendResetSubmit, this);
    this.signinSubmit = __bind(this.signinSubmit, this);
    return Auth.__super__.constructor.apply(this, arguments);
  }

  Auth.prototype.initialize = function() {
    this.isBusy = new Bacon.Bus();
    this.alert = new Bacon.Bus();
    this.success = new Bacon.Bus();
    this.signin = new Bacon.Bus();
    this.sendReset = new Bacon.Bus();
    this.add('alert', this.alert.toProperty());
    this.signin.onValue(this.signinSubmit);
    this.sendReset.onValue(this.sendResetSubmit);

    /*
    Redirect handler
    
    When a success respond to a sign in form submission, then get the `next`
    property value and redirect the user to this URL.
     */
    return this.success.map(this.get('next')).onValue(function(next) {
      return setTimeout(function() {
        return window.location.pathname = next;
      }, 500);
    });
  };


  /*
  Sign in submission
  
  Submit a form in an ajax request and handle its response in a Bacon stream.
  
  - `form`: an object containing the form values
   */

  Auth.prototype.signinSubmit = function(form) {
    var data, req;
    data = JSON.stringify({
      password: form.password
    });
    req = Bacon.fromPromise($.post(form.action, data));
    this.success.plug(req.map('.success'));
    this.alert.plug(req.map(false));
    this.alert.plug(req.errors().mapError({
      status: 'error',
      title: 'wrong password title',
      message: 'wrong password message'
    }));
    return this.isBusy.plug(req.mapEnd(false));
  };


  /*
  Reset link submission
  
  Submit the request to get a password recover link.
   */

  Auth.prototype.sendResetSubmit = function() {
    var reset;
    reset = Bacon.fromPromise($.post('/login/forgot'));
    return this.alert.plug(reset.map({
      status: 'success',
      title: 'recover sent title',
      message: 'recover sent message'
    }));
  };

  return Auth;

})(StateModel);
});

;require.register("states/registration", function(exports, require, module) {

/*
Registration state-machine

Exposed streams and properties to the Register* views.
 */
var Registration, StateModel,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

StateModel = require('lib/state_model');

module.exports = Registration = (function(_super) {
  __extends(Registration, _super);

  function Registration() {
    this.setEmailSubmit = __bind(this.setEmailSubmit, this);
    this.signupSubmit = __bind(this.signupSubmit, this);
    return Registration.__super__.constructor.apply(this, arguments);
  }


  /*
  Registration process consists of a progress across many screens, in a
  non-linear mode. So, to keep it consistent, we declare the flow between
  screens in this step var. Each step can declares:
  - next: the step that comes after
  - nextLabel: the label for the next button flow control
  - nocontrols: hide the flow controls
   */

  Registration.prototype.steps = {
    preset: {
      next: 'import',
      nextLabel: 'sign up'
    },
    "import": {
      next: 'email',
      nextLabel: 'skip'
    },
    import_google: {
      nocontrols: true
    },
    email: {
      next: 'setup',
      nextLabel: 'skip'
    },
    setup: {
      next: 'welcome',
      nocontrols: true
    },
    welcome: {
      nextLabel: 'welcome'
    }
  };

  Registration.prototype.initialize = function() {
    this.errors = new Bacon.Bus();
    this.initStep();
    this.initControls();
    this.initSignup();
    return this.initSetEmail();
  };


  /*
  Set step property
  
  A simple wrapper to push the new step value in the `step` property.
   */

  Registration.prototype.setStep = function(newStep) {
    return this.setStepBus.push(newStep);
  };


  /*
  Initialize step flow
  
  Declares the streams and properties that'll be used to control step flow.
   */

  Registration.prototype.initStep = function() {
    var step;
    this.setStepBus = new Bacon.Bus();
    this.stepValve = new Bacon.Bus();
    step = this.setStepBus.holdWhen(this.stepValve.startWith(false).toProperty()).filter((function(_this) {
      return function(step) {
        return __indexOf.call(Object.keys(_this.steps), step) >= 0;
      };
    })(this)).toProperty(null);
    this.add('step', step);
    return this.add('nextStep', step.map((function(_this) {
      return function(step) {
        var _ref;
        return ((_ref = _this.steps[step]) != null ? _ref.next : void 0) || null;
      };
    })(this)));
  };


  /*
  Initialize the controls flow
   */

  Registration.prototype.initControls = function() {
    var nextControl;
    this.nextEnabled = new Bacon.Bus();
    this.nextBusy = new Bacon.Bus();
    this.nextLabel = new Bacon.Bus();
    nextControl = Bacon.combineTemplate({
      enabled: this.nextEnabled.startWith(true).toProperty(),
      busy: this.nextBusy.startWith(false).toProperty(),
      label: this.nextLabel.startWith('next').toProperty(),
      visible: this.get('step').map((function(_this) {
        return function(step) {
          var _ref;
          return !((_ref = _this.steps[step]) != null ? _ref.nocontrols : void 0);
        };
      })(this))
    });
    this.nextLabel.plug(this.get('step').map((function(_this) {
      return function(step) {
        var _ref;
        return (_ref = _this.steps[step]) != null ? _ref.nextLabel : void 0;
      };
    })(this)));
    this.setStepBus.filter((function(_this) {
      return function(value) {
        return !(__indexOf.call(Object.keys(_this.steps), value) >= 0);
      };
    })(this)).onValue(function(path) {
      return window.location.pathname = path;
    });
    return this.add('nextControl', nextControl);
  };


  /*
  Initialize sign up form
   */

  Registration.prototype.initSignup = function() {
    this.signup = new Bacon.Bus();
    this.stepValve.plug(this.get('step').map(function(step) {
      return step === 'preset';
    }));
    this.nextEnabled.plug(this.get('step').map(function(step) {
      return step !== 'preset';
    }));
    return this.signup.onValue(this.signupSubmit);
  };


  /*
  Treats signup submission
  
  - data: an object containing the form input entries as key/values pairs
   */

  Registration.prototype.signupSubmit = function(data) {
    var req;
    req = Bacon.fromPromise($.post('/register', JSON.stringify(data)));
    req.subscribe(function() {
      return window.username = data['public_name'];
    });
    this.stepValve.plug(req.map(false));
    this.errors.plug(req.errors().mapError('.responseJSON.errors'));
    return this.nextBusy.plug(req.mapEnd(false));
  };


  /*
  Initialize email account creation form
  
  Simply creates a bus to get the form submission and subscribe the submission
  handler to this stream.
   */

  Registration.prototype.initSetEmail = function() {
    this.setEmail = new Bacon.Bus();
    return this.setEmail.onValue(this.setEmailSubmit);
  };


  /*
  Treats email account creation form
  
  - data: an object containing the form input entries as key/values pairs
   */

  Registration.prototype.setEmailSubmit = function(data) {
    var accountData, login;
    login = data['imap-login'] || data.email;
    accountData = {
      id: null,
      label: data.email,
      name: data.email.split('@')[0],
      login: login,
      password: data.password,
      accountType: "IMAP",
      draftMailbox: "",
      favoriteMailboxes: null,
      imapPort: data['imap-port'],
      imapSSL: data['imap-ssl'],
      imapServer: data['imap-server'],
      imapTLS: false,
      smtpLogin: data['smtp-login'] || login,
      smtpMethod: "PLAIN",
      smtpPassword: data['smtp-password'] || data.password,
      smtpPort: data['smtp-port'],
      smtpSSL: data['smtp-ssl'],
      smtpServer: data['smtp-server'] || data['imap-server'],
      smtpTLS: false,
      mailboxes: "",
      sentMailbox: "",
      trashMailbox: ""
    };
    return $.ajax({
      type: 'POST',
      url: '/apps/emails/account',
      data: JSON.stringify(accountData),
      contentType: "application/json; charset=utf-8",
      dataType: 'json'
    });
  };

  return Registration;

})(StateModel);
});

;require.register("views/app_layout", function(exports, require, module) {

/*
App Layout

Attach itself to the `[role=application] DOM node and declares the application
main region for its subviews.
 */
var AppLayout,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = AppLayout = (function(_super) {
  __extends(AppLayout, _super);

  function AppLayout() {
    return AppLayout.__super__.constructor.apply(this, arguments);
  }

  AppLayout.prototype.template = require('views/templates/layout_app');

  AppLayout.prototype.el = '[role=application]';

  AppLayout.prototype.regions = {
    content: '.container'
  };

  return AppLayout;

})(Mn.LayoutView);
});

;require.register("views/auth/feedback", function(exports, require, module) {
var AuthFeedbackView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = AuthFeedbackView = (function(_super) {
  __extends(AuthFeedbackView, _super);

  function AuthFeedbackView() {
    return AuthFeedbackView.__super__.constructor.apply(this, arguments);
  }

  AuthFeedbackView.prototype.template = require('views/templates/view_auth_feedback');

  AuthFeedbackView.prototype.ui = {
    forgot: 'a.forgot'
  };

  AuthFeedbackView.prototype.serializeData = function() {
    return _.extend(this.model.toJSON(), {
      forgot: this.options.forgot,
      prefix: this.options.prefix
    });
  };

  AuthFeedbackView.prototype.initialize = function() {
    var sendLink;
    this.model.get('alert').subscribe(this.render);
    this.model.alert.map(function(res) {
      if (res.status) {
        return res.status;
      } else {
        return null;
      }
    }).assign(this.$el, 'attr', 'class');
    if (this.options.forgot) {
      sendLink = this.$el.asEventStream('click', this.ui.forgot).doAction('.preventDefault');
      return this.model.sendReset.plug(sendLink);
    }
  };

  return AuthFeedbackView;

})(Mn.ItemView);
});

;require.register("views/auth/index", function(exports, require, module) {

/*
Main Login/ResetPassword view

Creates a view form that display the form to submit password (in sign in and
reset password mode). It inherits from `Mn.LayoutView` because it declares a
region to host form feedbacks (state-machine `alert` property).
 */
var AuthView, FeedbackView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

FeedbackView = require('views/auth/feedback');

module.exports = AuthView = (function(_super) {
  __extends(AuthView, _super);

  function AuthView() {
    return AuthView.__super__.constructor.apply(this, arguments);
  }

  AuthView.prototype.tagName = 'form';

  AuthView.prototype.className = function() {
    return "" + this.options.type + " auth";
  };

  AuthView.prototype.attributes = function() {
    var data;
    return data = {
      method: 'POST',
      action: this.options.backend
    };
  };

  AuthView.prototype.template = require('views/templates/view_auth');

  AuthView.prototype.regions = {
    'feedback': '.feedback'
  };

  AuthView.prototype.ui = {
    passwd: 'input[type=password]',
    submit: '.controls button[type=submit]'
  };


  /*
  Data exposed to template
  
  - username: username to display, gets from global vars
              (see server/views/index.jade#L14)
  - prefix: type is passed as prefix for locales translations
   */

  AuthView.prototype.serializeData = function() {
    return {
      username: window.username,
      prefix: this.options.type
    };
  };


  /*
  Initialize internals
  
  - streams outputted from DOM elements
  - properties extracted from streams
   */

  AuthView.prototype.initialize = function() {
    var form, formTpl, password, submit;
    password = this.$el.asEventStream('focus keyup blur', this.ui.passwd).map('.target.value').toProperty('');
    this.passwordEntered = password.map(function(value) {
      return !!value;
    });
    submit = this.$el.asEventStream('click', this.ui.submit).doAction('.preventDefault').filter(this.passwordEntered);
    formTpl = {
      password: password,
      action: this.options.backend
    };
    form = Bacon.combineTemplate(formTpl).sampledBy(submit);
    this.model.isBusy.plug(form.map(true));
    return this.model.signin.plug(form);
  };


  /*
  After rendering
  
  When template is rendered into the DOM, attach reactive actions to its
  elements.
   */

  AuthView.prototype.onRender = function() {
    this.showChildView('feedback', new FeedbackView({
      forgot: this.options.type === 'login',
      prefix: this.options.type,
      model: this.model
    }));
    this.ui.passwd.asEventStream('focus').assign(this.ui.passwd[0], 'select');
    setTimeout((function(_this) {
      return function() {
        return _this.ui.passwd.focus();
      };
    })(this), 100);
    setTimeout((function(_this) {
      return function() {
        return _this.ui.passwd.focus();
      };
    })(this), 300);
    this.model.isBusy.assign(this.ui.submit, 'attr', 'aria-busy');
    this.model.success.map((function(_this) {
      return function() {
        return $('<i/>', {
          "class": 'fa fa-check',
          text: t("" + _this.options.type + " auth success")
        });
      };
    })(this)).assign(this.ui.submit, 'html');
    this.model.success.assign(this.ui.submit, 'toggleClass', 'btn-success');
    return this.model.alert.assign(this.ui.passwd[0], 'select');
  };

  return AuthView;

})(Mn.LayoutView);
});

;require.register("views/lib/form_view", function(exports, require, module) {

/*
Form View

This is a top-level class that contains helpers for FormViews. It is not
intended to be used directly.
 */
var FormView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = FormView = (function(_super) {
  __extends(FormView, _super);

  FormView.prototype.tagName = 'form';

  FormView.prototype.ui = {
    labels: 'label.with-input',
    inputs: 'label input'
  };


  /*
  Prepare internal streams
   */

  function FormView() {
    FormView.__super__.constructor.apply(this, arguments);
    this.inputsStream = this.$el.asEventStream('keyup blur change', this.ui.inputs);
    this.submitStream = this.$el.asEventStream('submit').doAction('.preventDefault').filter((function(_this) {
      return function() {
        return _this.model.get('nextControl').map('.enabled');
      };
    })(this));
  }


  /*
  Initialize the form streams and properties
  
  This helper needs to be explicitely called in the child-class `onRender`
  method.
   */

  FormView.prototype.initForm = function() {
    var getValue, inputs, required;
    inputs = {};
    required = Bacon.constant(true);
    getValue = function(el) {
      if (el.type === 'checkbox') {
        return el.checked;
      } else {
        return el.value;
      }
    };
    this.ui.inputs.map((function(_this) {
      return function(index, el) {
        var property;
        property = _this.inputsStream.map('.target').filter(function(target) {
          return target === el;
        }).map(getValue).toProperty(getValue(el));
        inputs[el.name] = property;
        if (el.required) {
          return required = required.and(property.map(function(val) {
            return !!val;
          }));
        }
      };
    })(this));
    this.model.setStepBus.plug(this.submitStream.map(this.model.get('nextStep')));
    this.form = Bacon.combineTemplate(inputs).sampledBy(this.model.nextClickStream.merge(this.submitStream)).filter(required);
    return this.required = required;
  };


  /*
  Initialize the errors streams and actions
  
  This helper needs to be explicitely called in the child-class `onRender`
  method.
   */

  FormView.prototype.initErrors = function() {
    var $el, createMsg, isTruthy, name, property, _ref, _results;
    isTruthy = function(value) {
      return !!value;
    };
    createMsg = function(msg) {
      return $('<p/>', {
        "class": 'error',
        text: msg
      });
    };
    this.model.errors.filter(function(errors) {
      return !!errors;
    }).subscribe((function(_this) {
      return function() {
        return _this.ui.labels.find('.error').remove();
      };
    })(this));
    _ref = this.errors;
    _results = [];
    for (name in _ref) {
      property = _ref[name];
      $el = this.ui.labels.filter("[for=preset-" + name + "]");
      property.map(isTruthy).assign($el, 'attr', 'aria-invalid');
      _results.push(property.filter(isTruthy).map(createMsg).assign($el, 'append'));
    }
    return _results;
  };

  return FormView;

})(Mn.ItemView);
});

;require.register("views/register/controls", function(exports, require, module) {

/*
Register controls

A view dedicated to register flow control between its screens.
 */
var RegisterControlsView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = RegisterControlsView = (function(_super) {
  __extends(RegisterControlsView, _super);

  function RegisterControlsView() {
    return RegisterControlsView.__super__.constructor.apply(this, arguments);
  }

  RegisterControlsView.prototype.template = require('views/templates/view_register_controls');

  RegisterControlsView.prototype.ui = {
    'next': 'a.btn'
  };


  /*
  Initialize the view streams
   */

  RegisterControlsView.prototype.initialize = function() {
    var clickStream;
    clickStream = this.$el.asEventStream('click', this.ui.next).doAction('.preventDefault').map(function(e) {
      return e.target.href.split('=')[1] || '/';
    }).filter((function(_this) {
      return function() {
        return _this.model.get('nextControl').map('.enabled');
      };
    })(this));
    this.model.nextClickStream = clickStream;
    return this.model.setStepBus.plug(clickStream);
  };


  /*
  Assign reactive logics after rendering template
   */

  RegisterControlsView.prototype.onRender = function() {
    var isSkip;
    this.model.get('nextControl').map('.enabled').not().assign(this.ui.next, 'attr', 'aria-disabled');
    this.model.get('nextControl').map('.busy').assign(this.ui.next, 'attr', 'aria-busy');
    this.model.get('nextStep').map(function(step) {
      if (step) {
        return "register?step=" + step;
      } else {
        return '/';
      }
    }).assign(this.ui.next, 'attr', 'href');
    this.model.get('nextControl').map('.label').map(function(text) {
      return function() {
        return t(text);
      };
    }).assign(this.ui.next, 'text');
    isSkip = this.model.get('nextControl').map('.label').map(function(text) {
      return text === 'skip';
    });
    isSkip.assign(this.ui.next, 'toggleClass', 'btn-secondary');
    return isSkip.not().assign(this.ui.next, 'toggleClass', 'btn-primary');
  };

  return RegisterControlsView;

})(Mn.ItemView);
});

;require.register("views/register/email", function(exports, require, module) {

/*
Email account setting view

A view that contains a setup form for a primary email adress.
 */
var FormView, RegisterEmailView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

FormView = require('views/lib/form_view');

module.exports = RegisterEmailView = (function(_super) {
  __extends(RegisterEmailView, _super);

  function RegisterEmailView() {
    return RegisterEmailView.__super__.constructor.apply(this, arguments);
  }

  RegisterEmailView.prototype.className = 'email';

  RegisterEmailView.prototype.template = require('views/templates/view_register_email');


  /*
  Initialize internal streams
   */

  RegisterEmailView.prototype.initialize = function() {
    this.ui.legend = '.advanced legend';
    this.ui.adv = '.advanced .content';
    this.ui.ssl = 'input[type=checkbox][aria-controls]';
    this.showAdv = this.$el.asEventStream('click', this.ui.legend).scan(false, function(visible) {
      return !visible;
    });
    return this.sslCheck = this.$el.asEventStream('change', this.ui.ssl).map('.target');
  };


  /*
  Assign reactive actions
   */

  RegisterEmailView.prototype.onRender = function() {
    var _ref;
    this.showAdv.not().assign(this.ui.adv, 'attr', 'aria-hidden');
    this.showAdv.assign(this.ui.legend, 'attr', 'aria-hidden');
    if ((_ref = this.model.get('email')) != null) {
      _ref.assign(this.ui.inputs.filter('#email-email'), 'val');
    }
    this.initSSLCheckboxes();
    this.bindSMTPServer();
    this.initForm();
    this.model.setEmail.plug(this.form.filter((function(_this) {
      return function() {
        return _this.model.get('step').map(function(cur) {
          return cur === 'email' || cur === 'setup';
        });
      };
    })(this)));
    return this.model.nextLabel.plug(this.required.map(function(bool) {
      if (bool) {
        return 'add email';
      } else {
        return 'skip';
      }
    }));
  };


  /*
  Initialize the SSL checkboxes
  
  When clicking on a checkbox that controls an ssl-port input, then change
  this input value to pre-fill a right value, depending of the service and the
  state of the SSL checkbox.
   */

  RegisterEmailView.prototype.initSSLCheckboxes = function() {
    return this.ui.ssl.each((function(_this) {
      return function(indexs, el) {
        var control, service;
        service = el.id.match(/email-([a-z]{4})-ssl/i)[1];
        control = _this.$("#" + (el.getAttribute('aria-controls')));
        return _this.sslCheck.filter(function(target) {
          return target === el;
        }).map(function(target) {
          var ssl;
          ssl = target.checked;
          switch (service) {
            case 'imap':
              if (ssl) {
                return 993;
              } else {
                return 143;
              }
            case 'smtp':
              if (ssl) {
                return 465;
              } else {
                return 25;
              }
          }
        }).assign(control, 'val');
      };
    })(this));
  };


  /*
  Initialize smtp server input logic
  
  When fill the imap-server input, if the smtp-server input is empty or was
  never edited, then is takes the same value as the imap-server input. If it
  contains a custom value, it doesn't change.
   */

  RegisterEmailView.prototype.bindSMTPServer = function() {
    var imapServer, smtpServer;
    imapServer = this.ui.inputs.filter('#email-imap-server');
    smtpServer = this.ui.inputs.filter('#email-smtp-server');
    smtpServer.asEventStream('keyup').map(function(e) {
      return !!e.target.value.length;
    }).assign(smtpServer, 'data', 'edited');
    return imapServer.asEventStream('keyup').map('.target.value').filter(function() {
      return smtpServer.data('edited');
    }).assign(smtpServer, 'val');
  };

  return RegisterEmailView;

})(FormView);
});

;require.register("views/register/feedback", function(exports, require, module) {

/*
Register feedback

A view that display the current step in the register flow
 */
var RegisterFeedbackView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = RegisterFeedbackView = (function(_super) {
  __extends(RegisterFeedbackView, _super);

  function RegisterFeedbackView() {
    return RegisterFeedbackView.__super__.constructor.apply(this, arguments);
  }

  RegisterFeedbackView.prototype.template = require('views/templates/view_register_feedback');

  RegisterFeedbackView.prototype.onRender = function() {
    this.model.get('step').map(function(value) {
      return function() {
        return this.classList.contains(value);
      };
    }).assign(this.$('li'), 'attr', 'aria-selected');
    return this.model.get('step').map(function(step) {
      return /^welcome/.test(step);
    }).assign(this.$el, 'attr', 'aria-hidden');
  };

  return RegisterFeedbackView;

})(Mn.ItemView);
});

;require.register("views/register/import", function(exports, require, module) {
var RegisterImportView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = RegisterImportView = (function(_super) {
  __extends(RegisterImportView, _super);

  function RegisterImportView() {
    return RegisterImportView.__super__.constructor.apply(this, arguments);
  }

  RegisterImportView.prototype.className = 'import';

  RegisterImportView.prototype.template = require('views/templates/view_register_import');

  RegisterImportView.prototype.ui = {
    google: '#import-google'
  };

  RegisterImportView.prototype.initialize = function() {
    var stream;
    stream = this.$el.asEventStream('click', this.ui.google).doAction('.preventDefault').map(function(e) {
      return e.target.href.split('=')[1];
    });
    return this.model.setStepBus.plug(stream);
  };

  return RegisterImportView;

})(Mn.ItemView);
});

;require.register("views/register/import_google", function(exports, require, module) {

/*
Import Google step

This view do **not** rely on the machine state (except for the next stream push)
and uses basical Marionette logics to handle its internal events
 */
var RegisterImportGoogleView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = RegisterImportGoogleView = (function(_super) {
  __extends(RegisterImportGoogleView, _super);

  function RegisterImportGoogleView() {
    return RegisterImportGoogleView.__super__.constructor.apply(this, arguments);
  }

  RegisterImportGoogleView.prototype.className = 'import-google';

  RegisterImportGoogleView.prototype.template = require('views/templates/view_register_import_google');

  RegisterImportGoogleView.prototype.events = {
    'click #lg-ok': 'selectedScopes',
    'click #step-pastecode-ok': 'pastedCode',
    'click #cancel': 'cancel'
  };

  RegisterImportGoogleView.prototype.pastedCode = function(event) {
    var _ref;
    event.preventDefault();
    if ((_ref = this.popup) != null) {
      _ref.close();
    }
    this.changeStep('pickscope');
    this.auth_code = this.$("input:text[name=auth_code]").val();
    return this.$("input:text[name=auth_code]").val("");
  };

  RegisterImportGoogleView.prototype.selectedScopes = function(event) {
    var data, imports, scope;
    event.preventDefault();
    scope = {
      photos: false,
      calendars: this.$("input:checkbox[name=calendars]").prop("checked"),
      contacts: this.$("input:checkbox[name=contacts]").prop("checked"),
      sync_gmail: false
    };
    data = {
      auth_code: this.auth_code,
      scope: scope
    };
    $.post("/apps/import-from-google/lg", data);
    imports = [];
    if (scope.contacts) {
      imports.push('contacts');
    }
    if (scope.calendars) {
      imports.push('calendars');
    }
    if (imports.length) {
      this.model.add('imports', Bacon.constant(imports));
    }
    return this.model.setStep('setup');
  };

  RegisterImportGoogleView.prototype.changeStep = function(step) {
    this.$('.step').hide();
    this.$("#step-" + step).show();
    if (step === 'pastecode') {
      return this.$('#auth_code').focus();
    }
  };

  RegisterImportGoogleView.prototype.cancel = function() {
    return this.model.setStep('import');
  };

  RegisterImportGoogleView.prototype.onRender = function() {
    var clientID, oauthUrl, opts, scopes;
    this.changeStep('pastecode');
    opts = ['toolbars=0', 'width=700', 'height=600', 'left=200', 'top=200', 'scrollbars=1', 'resizable=1'].join(',');
    scopes = ['https://www.googleapis.com/auth/calendar.readonly', 'https://picasaweb.google.com/data/', 'https://www.googleapis.com/auth/contacts.readonly', 'email', 'https://mail.google.com/', 'profile'].join(' ');
    clientID = '260645850650-2oeufakc8ddbrn8p4o58emsl7u0r0c8s';
    clientID += '.apps.googleusercontent.com';
    oauthUrl = "https://accounts.google.com/o/oauth2/auth";
    oauthUrl += '?scope=' + encodeURIComponent(scopes);
    oauthUrl += '&response_type=code';
    oauthUrl += '&client_id=' + clientID;
    oauthUrl += '&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob';
    this.popup = window.open(oauthUrl, 'Google OAuth', opts);
    return this.changeStep('pastecode');
  };

  return RegisterImportGoogleView;

})(Mn.ItemView);
});

;require.register("views/register/index", function(exports, require, module) {

/*
Register root view

A Mn.LayoutView to handle the registration process and manipulates its views
flow easily. It declares 3 regions:
- a main region in which the current step view takes place
- a control region to display flow controls elements
- a feedback region to display the progression
 */
var ControlsView, FeedbackView, RegisterView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ControlsView = require('views/register/controls');

FeedbackView = require('views/register/feedback');

module.exports = RegisterView = (function(_super) {
  __extends(RegisterView, _super);

  function RegisterView() {
    this.swapStep = __bind(this.swapStep, this);
    return RegisterView.__super__.constructor.apply(this, arguments);
  }

  RegisterView.prototype.className = 'register';

  RegisterView.prototype.template = require('views/templates/view_base');

  RegisterView.prototype.regions = {
    'content': '[role=region]',
    'controls': '.controls',
    'feedback': '.feedback'
  };

  RegisterView.prototype.ui = {
    footer: 'footer'
  };

  RegisterView.prototype.initialize = function() {
    return this.model.get('step').onValue(this.swapStep);
  };


  /*
  After render template into the DOM
   */

  RegisterView.prototype.onRender = function() {
    this.showChildView('controls', new ControlsView({
      model: this.model
    }));
    this.showChildView('feedback', new FeedbackView({
      model: this.model
    }));
    return this.model.get('nextControl').map('.visible').not().assign(this.ui.footer, 'attr', 'aria-hidden');
  };


  /*
  Swap step child view
   */

  RegisterView.prototype.swapStep = function(step) {
    var StepView;
    if (!step) {
      return;
    }
    StepView = require("views/register/" + step);
    return this.showChildView('content', new StepView({
      model: this.model
    }));
  };

  return RegisterView;

})(Mn.LayoutView);
});

;require.register("views/register/preset", function(exports, require, module) {

/*
Presets view

This view display the form for the preset step
 */
var FormView, RegisterPresetView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

FormView = require('views/lib/form_view');

module.exports = RegisterPresetView = (function(_super) {
  __extends(RegisterPresetView, _super);

  function RegisterPresetView() {
    return RegisterPresetView.__super__.constructor.apply(this, arguments);
  }

  RegisterPresetView.prototype.className = 'preset';

  RegisterPresetView.prototype.attributes = {
    method: 'post',
    action: '/register'
  };

  RegisterPresetView.prototype.template = require('views/templates/view_register_preset');

  RegisterPresetView.prototype.serializeData = function() {
    return {
      timezones: require('lib/timezones')
    };
  };


  /*
  Initialize internal streams and properties
   */

  RegisterPresetView.prototype.initialize = function() {
    var email;
    email = this.$el.asEventStream('blur', '#preset-email').map('.target.value').toProperty('');
    this.model.add('email', email);
    return this.errors = {
      email: this.model.errors.map('.email'),
      password: this.model.errors.map('.password'),
      timezone: this.model.errors.map('.timezone')
    };
  };


  /*
  Assign reactive actions
   */

  RegisterPresetView.prototype.onRender = function() {
    var submit;
    this.initForm();
    this.initErrors();
    this.model.nextEnabled.plug(this.required.changes());
    submit = this.form.filter((function(_this) {
      return function() {
        return _this.model.get('step').map(function(cur) {
          return cur === 'preset';
        });
      };
    })(this));
    this.model.signup.plug(submit);
    return this.model.nextBusy.plug(submit.map(true));
  };

  return RegisterPresetView;

})(FormView);
});

;require.register("views/register/setup", function(exports, require, module) {

/*
Setup step view

This step display a counter as a progress bar that is:
- fake if the user do not import content (takes 8 seconds)
- indicates the import loading state, and have a minimal duration of 8 seconds
 */

/*
Helpers

This section declares top-level helpers
 */
var RegisterSetupView, fromSocket, getProgress, socket,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

socket = null;

fromSocket = function(event) {
  var endEvent;
  if (!socket) {
    socket = window.io(window.location.origin, {
      path: '/apps/import-from-google/socket.io',
      reconnectionDelayMax: 60000,
      reconectionDelay: 2000,
      reconnectionAttempts: 3
    });
  }
  endEvent = event === 'calendars' ? 'events' : event;
  return Bacon.fromBinder(function(sink) {
    sink(0);
    socket.on(event, function(data) {
      return sink(Math.floor(data.number / data.total * 100));
    });
    socket.on("" + endEvent + ".end", function() {
      sink(100);
      return sink(new Bacon.End());
    });
    return function() {};
  });
};

getProgress = function() {
  var sum;
  sum = [].reduce.call(arguments, (function(memo, val) {
    return memo + val;
  }), 0);
  return sum / arguments.length;
};


/*
Setup View
 */

module.exports = RegisterSetupView = (function(_super) {
  __extends(RegisterSetupView, _super);

  function RegisterSetupView() {
    this.initCounter = __bind(this.initCounter, this);
    return RegisterSetupView.__super__.constructor.apply(this, arguments);
  }

  RegisterSetupView.prototype.className = 'setup';

  RegisterSetupView.prototype.template = require('views/templates/view_register_setup');

  RegisterSetupView.prototype.ui = {
    bar: 'progress'
  };


  /*
  Initialize counter
  
  it takes care of the imported elements state (do we import something or not)
   */

  RegisterSetupView.prototype.initialize = function() {
    return this.model.get('imports').onValue(this.initCounter);
  };


  /*
  Assign the internal counter property to the progress bar
   */

  RegisterSetupView.prototype.onRender = function() {
    return this.progress.assign(this.ui.bar, 'val');
  };


  /*
  Creates a counter property from
  - a timer of 8 seconds
  - each imports feedbacks
   */

  RegisterSetupView.prototype.initCounter = function(imports) {
    var args, end, timer;
    timer = Bacon.interval(80, 1).take(100).scan(0, function(a, b) {
      return a + b;
    });
    if (imports) {
      args = [getProgress, timer.toProperty()];
      if (__indexOf.call(imports, 'contacts') >= 0) {
        args.push(fromSocket('contacts').toProperty());
      }
      if (__indexOf.call(imports, 'calendars') >= 0) {
        args.push(fromSocket('calendars').toProperty());
      }
      this.progress = Bacon.combineWith.apply(Bacon, args);
    } else {
      this.progress = timer.toProperty();
    }
    end = this.progress.filter(function(n) {
      return n >= 100;
    }).map(this.model.steps['setup'].next);
    return this.model.setStepBus.plug(end);
  };

  return RegisterSetupView;

})(Mn.ItemView);
});

;require.register("views/register/welcome", function(exports, require, module) {

/*
Welcome (last) step view

This view display the welcome wording and permit to pass to the login screen
 */
var RegisterWelcdomeView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = RegisterWelcdomeView = (function(_super) {
  __extends(RegisterWelcdomeView, _super);

  function RegisterWelcdomeView() {
    return RegisterWelcdomeView.__super__.constructor.apply(this, arguments);
  }

  RegisterWelcdomeView.prototype.className = 'welcome';

  RegisterWelcdomeView.prototype.template = require('views/templates/view_register_welcome');

  return RegisterWelcdomeView;

})(Mn.ItemView);
});

;require.register("views/templates/layout_app", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<section class=\"popup\"><header></header><div class=\"container\"></div></section>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/view_auth", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),prefix = locals_.prefix,username = locals_.username;
buf.push("<div role=\"region\"><h1>" + (jade.escape((jade_interp = t(prefix + ' welcome')) == null ? '' : jade_interp)) + " " + (jade.escape((jade_interp = username) == null ? '' : jade_interp)) + "</h1><p id=\"login-password-tip\" class=\"help\">" + (jade.escape(null == (jade_interp = t(prefix + ' enter your password')) ? "" : jade_interp)) + "</p><label" + (jade.attr("for", "" + (prefix) + "-password", true, false)) + (jade.attr("aria-describedby", "" + (prefix) + "-password-tip", true, false)) + " class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t(prefix + ' password')) ? "" : jade_interp)) + "</span><input" + (jade.attr("id", "" + (prefix) + "-password", true, false)) + " name=\"password\" type=\"password\" autofocus=\"autofocus\"/></label></div><footer><div class=\"controls\"><button type=\"submit\" class=\"btn btn-primary\">" + (jade.escape(null == (jade_interp = t(prefix + ' submit')) ? "" : jade_interp)) + "</button></div><div class=\"feedback\"></div></footer>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/view_auth_feedback", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),alert = locals_.alert,prefix = locals_.prefix,forgot = locals_.forgot,label = locals_.label;
if ( alert)
{
buf.push("<div class=\"alert\"><p><strong>" + (jade.escape(null == (jade_interp = t(prefix + ' ' + alert.title)) ? "" : jade_interp)) + "</strong></p><p>" + (jade.escape(null == (jade_interp = t(prefix + ' ' + alert.message)) ? "" : jade_interp)) + "</p></div>");
}
if ( forgot)
{
buf.push("<div class=\"recover\">");
label = t(alert && alert.status == 'success'? 'login recover again' : 'login recover')
buf.push("<a href=\"/login/forgot\" class=\"forgot\">" + (jade.escape(null == (jade_interp = label) ? "" : jade_interp)) + "</a></div>");
};return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/view_base", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div role=\"region\"></div><footer><div class=\"controls\"></div><div class=\"feedback\"></div></footer>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/view_register_controls", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<a href=\"/register?step=null\" class=\"btn btn-primary\">" + (jade.escape(null == (jade_interp = t('next')) ? "" : jade_interp)) + "</a>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/view_register_email", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<h2>" + (jade.escape(null == (jade_interp = t('email caption')) ? "" : jade_interp)) + "</h2><label for=\"email-email\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('email email')) ? "" : jade_interp)) + "</span><input id=\"email-email\" type=\"email\" name=\"email\" required=\"required\"/></label><label for=\"email-password\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('email password')) ? "" : jade_interp)) + "</span><input id=\"email-password\" type=\"password\" name=\"password\" required=\"required\"/></label><div class=\"input-group input-group-02-third\"><label for=\"email-imap-server\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('email imap server')) ? "" : jade_interp)) + "</span><input id=\"email-imap-server\" type=\"text\" name=\"imap-server\" required=\"required\"/></label><label for=\"email-imap-port\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('email imap port')) ? "" : jade_interp)) + "</span><input id=\"email-imap-port\" type=\"number\" name=\"imap-port\" required=\"required\" value=\"993\"/></label></div><label for=\"email-imap-ssl\" class=\"checkbox\"><input id=\"email-imap-ssl\" type=\"checkbox\" name=\"imap-ssl\" checked=\"checked\" aria-controls=\"email-imap-port\"/><span>" + (jade.escape(null == (jade_interp = t('email imap ssl')) ? "" : jade_interp)) + "</span></label><fieldset class=\"advanced\"><legend>" + (jade.escape(null == (jade_interp = t('email show advanced')) ? "" : jade_interp)) + "</legend><div class=\"content\"><label for=\"email-imap-login\" aria-describedby=\"email-imap-login-tip\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('email imap login')) ? "" : jade_interp)) + "</span><input id=\"email-imap-login\" type=\"text\" name=\"imap-login\"/></label><p id=\"email-login-tip\" class=\"tips\">" + (jade.escape(null == (jade_interp = t('email imap login tip')) ? "" : jade_interp)) + "</p><hr/><div class=\"input-group input-group-02-third\"><label for=\"email-smtp-server\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('email smtp server')) ? "" : jade_interp)) + "</span><input id=\"email-smtp-server\" type=\"text\" name=\"smtp-server\"/></label><label for=\"email-smtp-port\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('email smtp port')) ? "" : jade_interp)) + "</span><input id=\"email-smtp-port\" type=\"number\" name=\"smtp-port\" value=\"465\"/></label></div><label for=\"email-smtp-ssl\" class=\"checkbox\"><input id=\"email-smtp-ssl\" type=\"checkbox\" name=\"smtp-ssl\" checked=\"checked\" aria-controls=\"email-smtp-port\"/><span>" + (jade.escape(null == (jade_interp = t('email smtp ssl')) ? "" : jade_interp)) + "</span></label><label for=\"email-smtp-login\" aria-describedby=\"email-smtp-login-tip\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('email smtp login')) ? "" : jade_interp)) + "</span><input id=\"email-smtp-login\" type=\"email\" name=\"smtp-login\"/></label><p id=\"email-login-tip\" class=\"tips\">" + (jade.escape(null == (jade_interp = t('email smtp login tip')) ? "" : jade_interp)) + "</p><label for=\"email-smtp-password\" aria-describedby=\"email-smtp-password-tip\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('email smtp password')) ? "" : jade_interp)) + "</span><input id=\"email-password\" type=\"password\" name=\"smtp-password\"/></label><p id=\"email-login-tip\" class=\"tips\">" + (jade.escape(null == (jade_interp = t('email smtp password tip')) ? "" : jade_interp)) + "</p></div></fieldset><p id=\"email-email-tip\" class=\"tips\">" + (jade.escape(null == (jade_interp = t('email email tip')) ? "" : jade_interp)) + "</p>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/view_register_feedback", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<ul><li class=\"preset\">" + (jade.escape(null == (jade_interp = t('step preset')) ? "" : jade_interp)) + "</li><li class=\"import\">" + (jade.escape(null == (jade_interp = t('step import')) ? "" : jade_interp)) + "</li><li class=\"email\">" + (jade.escape(null == (jade_interp = t('step email settings')) ? "" : jade_interp)) + "</li></ul>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/view_register_import", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div id=\"import-google\" class=\"content-block\"><div class=\"content-illustration google-services\"></div><h2>" + (jade.escape(null == (jade_interp = t('import google account')) ? "" : jade_interp)) + "</h2><p>" + (jade.escape(null == (jade_interp = t('import google account tip')) ? "" : jade_interp)) + "</p><a id=\"import-google\" type=\"button\" href=\"/register?step=import_google\" class=\"btn btn-primary\">" + (jade.escape(null == (jade_interp = t('import google account sign in')) ? "" : jade_interp)) + "</a></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/view_register_import_google", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div id=\"import-google\" class=\"content-block\"><h2>" + (jade.escape(null == (jade_interp = t('leave google title')) ? "" : jade_interp)) + "</h2><section id=\"step-pastecode\" class=\"step\"><p>" + (jade.escape(null == (jade_interp = t("leave google code content")) ? "" : jade_interp)) + "</p><form><label for=\"google-code\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('leave google code')) ? "" : jade_interp)) + "</span><input id=\"auth_code\" type=\"text\" name=\"auth_code\" required=\"required\" autofocus=\"autofocus\"/></label><div class=\"btn-group btn-group-02\"><button id=\"cancel\" class=\"btn btn-secondary\">" + (jade.escape(null == (jade_interp = t('cancel')) ? "" : jade_interp)) + "</button><button id=\"step-pastecode-ok\" class=\"btn btn-primary\">" + (jade.escape(null == (jade_interp = t('confirm')) ? "" : jade_interp)) + "</button></div></form></section><section id=\"step-pickscope\" class=\"step google-services-list\"><p>" + (jade.escape(null == (jade_interp = t('leave google choice')) ? "" : jade_interp)) + "</p><label for=\"google-contacts-import\"><input id=\"google-contacts-import\" type=\"checkbox\" name=\"contacts\" value=\"contacts\" checked=\"checked\"/><span class=\"google-services-icons contacts\"></span><span>" + (jade.escape(null == (jade_interp = t("leave google choice contacts")) ? "" : jade_interp)) + "</span></label><label for=\"google-calendar-import\"><input id=\"google-calendar-import\" type=\"checkbox\" name=\"calendars\" value=\"calendars\" checked=\"checked\"/><span class=\"google-services-icons calendar\"></span><span>" + (jade.escape(null == (jade_interp = t("leave google choice calendar")) ? "" : jade_interp)) + "</span></label><div class=\"btn-group btn-group-02\"><button id=\"cancel\" class=\"btn btn-secondary\">" + (jade.escape(null == (jade_interp = t('cancel')) ? "" : jade_interp)) + "</button><button id=\"lg-ok\" class=\"btn btn-primary\">" + (jade.escape(null == (jade_interp = t('leave google confirm')) ? "" : jade_interp)) + "</button></div></section></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/view_register_preset", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),timezones = locals_.timezones;
buf.push("<label for=\"preset-email\" aria-describedby=\"preset-email-tip\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('preset email')) ? "" : jade_interp)) + "</span><input id=\"preset-email\" type=\"email\" name=\"email\" autofocus=\"autofocus\" required=\"required\"/><span class=\"indicator\"><span class=\"fa fa-exclamation-triangle\"></span></span></label><p id=\"preset-email-tip\" class=\"tips\">" + (jade.escape(null == (jade_interp = t('preset email tip')) ? "" : jade_interp)) + "</p><label for=\"preset-name\" aria-describedby=\"preset-name-tip\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('preset name')) ? "" : jade_interp)) + "</span><input id=\"preset-name\" type=\"text\" name=\"public_name\" required=\"required\"/></label><p id=\"preset-name-tip\" class=\"tips\">" + (jade.escape(null == (jade_interp = t('preset name tip')) ? "" : jade_interp)) + "</p><label for=\"preset-password\" aria-describedby=\"preset-password-tip\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('preset password')) ? "" : jade_interp)) + "</span><input id=\"preset-password\" type=\"password\" name=\"password\" required=\"required\"/><span class=\"indicator\"><span class=\"fa fa-exclamation-triangle\"></span></span></label><p id=\"preset-email-tip\" class=\"tips\">" + (jade.escape(null == (jade_interp = t('preset password tip')) ? "" : jade_interp)) + "</p><label for=\"preset-timezone\" aria-describedby=\"preset-timezone-tip\" class=\"with-input\"><span>" + (jade.escape(null == (jade_interp = t('preset timezone')) ? "" : jade_interp)) + "</span><input id=\"preset-timezone\" type=\"text\" name=\"timezone\" list=\"preset-timezone-datalist\" required=\"required\"/><datalist id=\"preset-timezone-datalist\">");
// iterate timezones
;(function(){
  var $$obj = timezones;
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var timezone = $$obj[$index];

buf.push("<option" + (jade.attr("value", timezone, true, false)) + "></option>");
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var timezone = $$obj[$index];

buf.push("<option" + (jade.attr("value", timezone, true, false)) + "></option>");
    }

  }
}).call(this);

buf.push("</datalist><span class=\"indicator\"><span class=\"fa fa-exclamation-triangle\"></span></span></label><p id=\"preset-timezone-tip\" class=\"tips\">" + (jade.escape(null == (jade_interp = t('preset timezone tip')) ? "" : jade_interp)) + "</p><div class=\"checkboxes\"><label for=\"preset-help-us\" class=\"checkbox\"><input id=\"preset-help-us\" type=\"checkbox\" name=\"allow_stats\" checked=\"checked\"/><span>" + (jade.escape(null == (jade_interp = t('preset opt-in help')) ? "" : jade_interp)) + "</span></label></div><button type=\"submit\" aria-hidden=\"true\"></button>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/view_register_setup", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<h1>" + (jade.escape(null == (jade_interp = t('setup title')) ? "" : jade_interp)) + "</h1><p class=\"help\">" + (jade.escape(null == (jade_interp = t('setup message')) ? "" : jade_interp)) + "</p><progress value=\"0\" max=\"100\"></progress><h1>" + (jade.escape(null == (jade_interp = t('setup on mobile title')) ? "" : jade_interp)) + "</h1><p class=\"help\">" + (jade.escape(null == (jade_interp = t('setup on mobile message')) ? "" : jade_interp)) + "</p><a href=\"https://play.google.com/store/apps/details?id=io.cozy.files_client\" target=\"_blank\" class=\"btn-store\"><img src=\"/img/google-play-btn.svg\" alt=\"Get it on Google Play\"/></a>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/view_register_welcome", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<h1>" + (jade.escape(null == (jade_interp = t('welcome title')) ? "" : jade_interp)) + "</h1><p class=\"help\">" + (jade.escape(null == (jade_interp = t('welcome message')) ? "" : jade_interp)) + "</p>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;
//# sourceMappingURL=app.js.map