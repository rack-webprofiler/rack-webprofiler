# Changelog

## Unplanned

### Features

  * Create a collector to show informations about CPU usage.
  * Create a collector to list all `.inspect` method calls.
  * Create a collector to list the HTTP calls.
  * Create a collector to list the ajax requests.
  * Catch 500 or exceptions.




## v0.1.1

### Fixes

  * Debug stylesheets.
  * Small code cleanup.


## v0.1.0

### Features

  * Separate DSL `collector_name` in `identifier` and `name` methods.
  * Start optimizing css.
  * Improve documentation and code comments.
  * Move collectors into collectors folder instead collector.
  * Cleanup files.
  * Improve tests.

### Fixes

 * Debug SQLite database stabilty by using a single thread.


## v0.1.0.beta2

### Features

  * Create a view class to manage template and create helpers. And
    cleanup all views.
  * Remove Sinatra and Rails linked elements (now in separate gems).
  * Improve stability.


## v0.1.0.beta1

### Features

  * Friendly UI.
  * Improve development environment.
  * Complete collectors.
  * Serve toolbar assets dynamically.
  * Improve tests.


## v0.1.0.pre.alpha1

### Features

  * Web toolbar injected into text/html responses.
  * Have a panel who list all the request stored into the profiler and show more informations than the toolbar.
  * Provide a nice DSL for collector to allow adding a new collector easily.
  * Create a execution time collector.
  * Create a collector to show which version of ruby it is used.
  * Create a collector to show the Rack request informations.
  * Create a collector to show which Rack version is used and the current environment.
