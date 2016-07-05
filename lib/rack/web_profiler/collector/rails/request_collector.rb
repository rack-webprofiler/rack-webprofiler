module Rack
  class WebProfiler::Collector::Rails::RequestCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "rails_request"
    position       1

    collect do |request, response|
      route, _matches, request_params = find_route(request)

      store :request_path,    request.path
      store :request_method,  request.request_method
      store :request_params,  request_params || {}
      store :request_cookies, request.cookies
      store :request_get,     request.GET
      store :request_post,    request.POST
      # store :rack_env,        request.env.each { |k, v| v.to_s }
      # puts request.env.map{ |k, v| k => v.to_s }
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

    class << self
      def find_route(request)
        Rails.application.routes.router.recognize(request) do |route, matches, params|
      return [route, matches, params]
    end
      end
    end
  end
end

__END__
<%# content_for :tab do %>
  <%= data[:response_status] %> | <%= data[:request_method] %> <%= data[:request_path] %>
<%# end %>
