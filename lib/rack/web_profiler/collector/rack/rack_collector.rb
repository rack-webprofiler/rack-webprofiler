module Rack
  class WebProfiler::Collector::Rack::RackCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "rack"
    position       1

    collect do |_request, _response|
      store :rack_version, Rack.release
    end

    template __FILE__, type: :DATA

    is_enabled? -> { !defined?(Rails) && !defined?(Sinatra) }
  end
end

__END__
<%# content_for :tab do %>
  <%= @data[:rack_version] %>
<%# end %>
