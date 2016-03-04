# Cozy-proxy front app

This frontend application serves the cozy-proxy browser app. It relies on the server `views/index.jade` for is base markup. It is engaged when user try to access the following pages:

- login
- reset password
- onboarding (all its subscreens)


## Development

*TL;DR*:

```sh
# in your top-level cozy-proxy directory
$ npm run watch
```

Then point your browser to http://localhost:3000.

***

We use [Webpack](https://webpack.github.io/docs/) as build tool, and every dependencies are loaded _via_ NPM. All development tasks are loaded through NPM scripts at the project top-level, so you should launch the development watcher from the `cozy-proxy` directory by running `npm run watch`. It'll load the server part in watch mode, the webpack builder in watch mode too, and proxify the server behind [BrowserSync](https://browsersync.io/) for hot-reloading. BrowserSync exposes at [localhost:3000](http://localhost:3000) by default.


## Librairies

This front-end app have inline code documentation, so you can read it as well as you browse its files and logics, but you should be aware of its libraries in use:
* Backbone is used for a quick and valid components architecture, like views
* Marionette is the framework used upon Backbone to have a more clever and easier way to deal with views (like layouts, regions, and views switching)
* Bacon is used here especially because the forms in the onboarding needs many interactions and its pattern allow us to quickly deals with them, regardless of their origins.


## Architecture

### Files structure

The app is organized in the following way:

```txt
- app/
  |- initialize.coffee       # sets the browser environment and launch app
  |- application.coffee      # Backbone.Marionette application singleton instance
  |
  |- routes
  |  `- index.coffee         # the default routes a-la-backbone
  |
  |- views                   # all views used by the application
  |  |- templates            # all views templates, named as '[layout|view]_[module]_[viewname].jade'
  |  |- lib                  # the top-classes used for views inheritance (such as FormView)
  |  |- [module]             # a module folder containing all its subviews components
  |  |  |- index.coffee      # the modules's root view
  |  |  `- [view].coffee     # a subview component
  |  `- app_layout.coffee    # application's root layout view
  |
  |- states                  # the states-machines, aka viewModel Bacon objects used by views
  |
  |- lib                     # shared helpers, such as the state-machine root class
  |
  |- locales                 # all front-end app locales, organized per locale
  |  `- en.coffee            # EN_us locale, consumed by Polyglot.js
  |
  |- styles                  # all Stylus (CSS) sheets
  |  |- app.styl             # the whole app stylesheet
  |  |- base                 # the shared rules framework
  |  `- components           # specific app stylesheets, organized per component
  |
  `- assets                  # frontend assets referenced in modules

- vendor
  `- assets                  # frontend assets directly copied to build
  ```

### App workflow

So, what happens when you request an URL such as `/register?step=preset` in the front app ? Assumed this is the first page you visit, here is the step-by-step workflow:

1. You're markup is loaded, then the `initialize` function is executed when js main file is loaded
2. The `initialize` loads Polyglot and its dictionary based on the `html[lang]` attribute value, exposes its localization helper, and then launch application
3. The `application` load its router (`routes/index`), its layout view (`views/app_layout`) which prepares regions, and starts Backbone.history
4. The `router` parse the URL and execute the dedicated route control. This one will:
  1. load the state-machine concerned (`registration` in our exemple URL)
  2. load the module view (here `views/register/index`) and pass the model at initialization
5. The state-machine starts:
  1. it creates some Bacon.Bus() to receive later streams
  2. it may creates some properties useful for views
6. The root module view (which is often a Mn.LayoutView with regions) starts its subcomponents views:
  1. each subcomponent view uses the same state-machine as the root view, so each module share all its state across components
  2. subcomponent view initialize its streams, which can be used internally or exposed in a state-machine Bus
  3. subcomponents uses `onRender` hook to assign streams and properties to DOM elements and prepare the reactive actions

Your app is now fully loaded. What happens when you interact with it, by submitting a `form` by example ?

1. Your form, as a (complex-hash of) property, is streamed to the machine-state
2. The Buses turns the form property to its subscribers:
  1. if the view needs to react (e.g. state the submit button `aria-busy` to `true`), it does
  2. the state-machine internal logics are triggered (e.g. sending form through ajax request)
3. Then the internal state-machine logics are also plugged in Buses, so when it gets its response (e.g. the ajax promise), the event is mapped and streamed to its subscribers, mostly view reactions and transformations.

### Example

All right, explore an example with the register screen and its (many) subscreens steps. How does its works? Exactly like we say before, so:

1. you click the next/skip button
2. the event streamed to the state-machine, and the `step` property is update the the new step value (e.g. `preset` becomes `import`)
3. this changes is streamed to its subscribers:
  1. the `nextStep` and `previousStep` properties are also updated to reflect their new state
  2. the `register` root module view switch the step:
    1. it loads a new subview, passing the machine state to it, and switch it in its main region
    2. the instanciated subview creates its own streams and properties if needed and plugged them to the state-machine
  3. the router updates the browser navigation URL to reflect is new state (e.g. `/register?step=import`)

That's all.


## Ready to go

You'll probably want to be more aware about Bacon logics. In this project, it's extremely useful because all you need to do is to plug your front events to the right streams, and assign the streams to the views elements transforms. Be careful to always place logics in state-machines, the views _should_ never do things by themselves. If you follow this principles, all things will cascade cleverly and smoothly through your app.

Now go to read the code ;).
