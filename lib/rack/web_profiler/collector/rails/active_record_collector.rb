module Rack
  class WebProfiler::Collector::Rails::ActiveRecordCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "rails_activerecord"
    position       1

    collect do |_request, _response|
      store :sql_requests, []
    end

    template __FILE__, type: :DATA

    is_enabled? -> { defined? ActiveRecord }
  end
end

# See: https://github.com/noahd1/oink/blob/master/lib/oink/middleware.rb#L46

__END__
<%# content_for :tab do %>

<%# end %>
