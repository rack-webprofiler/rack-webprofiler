module Rack
  class WebProfiler::Collector::Rails::LoggerCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "rails_logger"
    position       1

    collect do |_request, _response|
    end

    template __FILE__, type: :DATA

    is_enabled? -> { defined? Rails }
  end
end

__END__
<%# content_for :tab do %>

<%# end %>
