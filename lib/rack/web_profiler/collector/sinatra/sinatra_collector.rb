module Rack
  class WebProfiler::Collector::Sinatra::SinatraCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "sinatra"
    position       1

    collect do |_request, _response|
      store :sinatra_version, Sinatra::VERSION
      store :sinatra_env,     Sinatra::Base.environment
      store :sinatra_doc_url, "http://www.sinatrarb.com/documentation.html"
    end

    template __FILE__, type: :DATA

    is_enabled? -> { defined? Sinatra }
  end
end

__END__
<%# content_for :tab do %>
  <%= data[:sinatra_version] %> | <%= data[:sinatra_env] %>
<%# end %>
