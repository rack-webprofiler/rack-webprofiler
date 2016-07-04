module Rack
  class WebProfiler::Collector::TimeCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "time"
    position       3

    collect do |request, _response|
      store :runtime, request.runtime

      status :warning if request.runtime >= 500
    end

    template __FILE__, type: :DATA
  end
end

__END__
<%# content_for :tab do %>
  <%= (data[:runtime] * 1000.0).round(2) %> ms
<%# end %>
