# @title Getting Started Guide

# Getting Started



## Installation

Add this line to your application's Gemfile:

```ruby
gem "rack-webprofiler"
```

## Usage

```ruby
home = lambda { |_env|
  [200, { "Content-Type" => "text/html" }, ["<html><body>Hello world!</body></html>"]]
}

builder = Rack::Builder.new do
  use Rack::WebProfiler

  map('/') { run home }
end

run builder
```


## Configuration

You can specify the temporary directory. It is used to save the SQlite database.

```ruby
use Rack::WebProfiler, tmp_dir: File.expand_path("/tmp", __FILE__)

# OR

use Rack::WebProfiler.config do |c|
  c.tmp_dir = File.expand_path("/tmp", __FILE__)
end
```


## Create your own collector

It's quite simple to create your own collector with the DSL. You have to
create a new class who include `rack-profiler` [DSL](./DSL.md) then use
the methods.


## HTTP Headers

* `X-RackWebProfiler-Token`: returns the current profiler token.
* `X-RackWebProfiler-Url`: returns the current profiler url.
