require "bundler/setup"
require "rack/webprofiler"
require "rack"

# An example of a custom collector.
#
# module MyCollector
#   class Profiler::Collector::TimeCollector
#     include Rack::WebProfiler::Collector::DSL
#
#     icon ""
#
#     collector_name "my_collector"
#     position       2
#
#     collect do |request, response|
#       store :runtime, request.runtime
#     end
#
#     template "
# <% content_for :tab do %>
#   <%= data[:runtime] %>
# <% end %>
# "
#   end
# end

home = lambda { |_env|
  [200, { "Content-Type" => "text/html" }, [<<-'HTML'
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Rack WebProfiler test</title>
  </head>

  <body>
    <p>Hello world!</p>
  </body>
</html>
HTML
]]
}

builder = Rack::Builder.new do
  use Rack::WebProfiler, tmp_dir: File.expand_path("../tmp", __FILE__)
  use Rack::ShowExceptions

  map('/') { run home }
end

run builder
