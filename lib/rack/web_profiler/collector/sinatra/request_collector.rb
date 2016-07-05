module Rack
  class WebProfiler::Collector::Sinatra::RequestCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "sinatra_request"
    position       2

    collect do |request, response|
      store :request_path,    request.path
      store :request_method,  request.request_method
      store :request_cookies, request.cookies
      store :request_get,     request.GET
      store :request_post,    request.POST
      # store :rack_env,        request.env.each { |k, v| v.to_s }
      # puts request.env.map{ |k, v| k => v.to_s }
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
  <%= data[:response_status] %> | <%= data[:request_method] %> <%= data[:request_path] %>
<%# end %>
