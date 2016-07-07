module Rack
  class WebProfiler::Collector::Sinatra::RequestCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "sinatra_request"
    position       2

    collect do |request, response|
      store :request_headers, []
      store :request_path,    request.path
      store :request_method,  request.request_method
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
<% content_for :tab do %>
  <%= data[:response_status] %> | <%= data[:request_method] %> <%= data[:request_path] %>
<% end %>

<% content_for :panel do %>
  <h3>GET</h3>
  <table>
    <thead>
      <tr>
        <th>Key</th>
        <th>Value</th>
      </tr>
    <thead>
    <tbody>
    <% data[:request_get].each do |k, v| %>
      <tr>
        <td><%= k %></td>
        <td><%= v %></td>
      </tr>
    <% end %>
    </tbody>
  </table>

  <h3>POST</h3>
  <table>
    <thead>
      <tr>
        <th>Key</th>
        <th>Value</th>
      </tr>
    <thead>
    <tbody>
    <% data[:request_post].each do |k, v| %>
      <tr>
        <td><%= k %></td>
        <td><%= v %></td>
      </tr>
    <% end %>
    </tbody>
  </table>

  <h3>Request headers</h3>
  <table>
    <thead>
      <tr>
        <th>Name</th>
        <th>Version</th>
      </tr>
    <thead>
    <tbody>
    <% data[:request_headers].each do |h| %>
      <tr>
        <td><%= h.inspect %></td>
        <td><%= h.inspect %></td>
      </tr>
    <% end %>
    </tbody>
  </table>


  <h3>Response headers</h3>
  <table>
    <thead>
      <tr>
        <th>Name</th>
        <th>Version</th>
      </tr>
    <thead>
    <tbody>
    <% data[:response_headers].each do |k, v| %>
      <tr>
        <td><%= k %></td>
        <td><%= v %></td>
      </tr>
    <% end %>
    </tbody>
  </table>
<% end %>
