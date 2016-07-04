module Rack
  class WebProfiler::Collector::Sinatra::RequestCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "sinatra_request"
    position       2

    collect do |request, response|
      store :request_path,    request.path
      store :response_status, response.status

      if response.successful?
        status :success
      elsif response.redirection?
        status :warning
      else
        status :error
      end
    end

    template __FILE__, type: :DATA

    is_enabled? -> { defined? Sinatra }
  end
end

__END__
<%# content_for :tab do %>
  <%= data[:response_status] %> - <%= data[:request_path] %>
<%# end %>
