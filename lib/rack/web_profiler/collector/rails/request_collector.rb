module Rack
  class WebProfiler::Collector::Rails::RequestCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "rails_request"
    position       1

    collect do |request, response|
      route, matches, request_params = [nil, nil, nil]

      Rails.application.routes.router.recognize(request) do |route, matches, params|
        route, matches, request_params = [route, matches, params]
      end

      store :request_path,    request.path
      store :request_method,  request.request_method
      store :request_params,  request_params || {}
      store :response_status, response.status
      store :route_name,      route.nil? ? nil : route.name

      if response.successful?
        status :success
      elsif response.redirection?
        status :warning
      else
        status :error
      end
    end

    template __FILE__, type: :DATA

    is_enabled? -> { defined? Rails }
  end
end

__END__
<%# content_for :tab do %>
  <%= data[:response_status] %> | <%= data[:request_method] %> <%= data[:request_path] %>
<%# end %>
