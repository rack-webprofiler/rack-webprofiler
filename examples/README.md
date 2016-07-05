# Examples

```shell
$ rackup rack/config.ru
$ rackup sinatra/config.ru
```
# How to create a custom collector

## What is a collector

A collector is a class who permit retrieve profiler data. And also create a tab and show content into the toolbar.

## The class

```ruby
class MyCustomCollector
  include Rack::WebProfiler::Collector::DSL

  collector_name "my_collector" # Technical name of the collector.
  icon     ""                   # Base64 encoded image for the icon collector.
  position 0                    # Position of the collector in the toolbar.

  # Retrieve the env, the request and the response
  # to collect the needed information. Then save datas
  # and show them in the profiler toolbar and panel.
  collect do |env, request, response|
    store :version, MyApp::VERSION
    store :list, ["value1", "value2"]
  end

  # The path of the collector template.
  # May be with some options to know if we show the collector
  # on tab and/or panel.
  template "../path/to/template.erb"
  # Or
  # template __FILE__, type: :DATA

  # To know if the collector must be enabled.
  # Usefull to load collector only if a gem is installed.
  is_enabled? -> { defined? MyApp }
end
```

And you have to register it

```ruby
Rack::WebProfiler.register_collector MyCustomCollector
```

You could also unregister a collector

```ruby
Rack::WebProfiler.unregister_collector MyCustomCollector
```
