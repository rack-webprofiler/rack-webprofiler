module Rack
  class WebProfiler::Collector::RequestCollector
    include Rack::WebProfiler::Collector::DSL

    icon <<-'ICON'
data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PHN2ZyB3aWR0aD0iMjBweCIgaGVpZ2h0PSIyMHB4IiB2aWV3Qm94PSIwIDAgMjAgMjAiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+ICAgICAgICA8dGl0bGU+T3ZhbCA3IENvcHkgMjwvdGl0bGU+ICAgIDxkZXNjPkNyZWF0ZWQgd2l0aCBTa2V0Y2guPC9kZXNjPiAgICA8ZGVmcz48L2RlZnM+ICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPiAgICAgICAgPGcgaWQ9IkRlc2t0b3AtMiIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTEwLjAwMDAwMCwgLTEzMC4wMDAwMDApIiBmaWxsPSIjNTg1NDczIj4gICAgICAgICAgICA8ZyBpZD0iUmVxdWVzdCIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMC4wMDAwMDAsIDEyMC4wMDAwMDApIj4gICAgICAgICAgICAgICAgPHBhdGggZD0iTTE3LjY3OTE5MTIsMTMuNDA2NDMyMiBDMTguMTAzNzAxMiwxMy4yNTUzNzMzIDE4LjU0NzA4OSwxMy4xNDQ1ODY0IDE5LjAwNDgzMTcsMTMuMDc4NjI3OCBMMTkuMDA0ODMxNywxMCBMMjAuOTk1MTY4MywxMCBMMjAuOTk1MTY4MywxMy4wNzg2Mjc4IEMyMS40NTI5MTEsMTMuMTQ0NTg2NCAyMS44OTYyOTg4LDEzLjI1NTM3MzMgMjIuMzIwODA4OCwxMy40MDY0MzIyIEwyMy43NjY1Mzg2LDEwLjY4NzQxIEwyNS41MjM5MDE1LDExLjYyMTgxNjUgTDI0LjA4MDM0MDcsMTQuMzM2NzU5NiBDMjQuNDU0NDUyLDE0LjYwOTU2NTUgMjQuODAwNTkwMywxNC45MTg5MDYzIDI1LjExMzU5ODIsMTUuMjU5NTg2NCBMMjcuNjI0NzkyLDEzLjUwMTIyOTYgTDI4Ljc2NjQwMjIsMTUuMTMxNjE3OSBMMjYuMjM5NDcyLDE2LjkwMDk5MzUgQzI2LjQ0Mjk1ODQsMTcuMzEyNjE1IDI2LjYwNzQ4OTQsMTcuNzQ3MjEzIDI2LjcyODIwMjgsMTguMTk5ODg5MyBMMjkuNzc1NjgxNCwxNy44MjU3MDU5IEwzMC4wMTgyNDI0LDE5LjgwMTIwNjkgTDI2Ljk2NDU5ODcsMjAuMTc2MTQ3MiBDMjYuOTU0Njg2MiwyMC42NDkzNjI3IDI2Ljg5ODI3NTUsMjEuMTExMDU1NiAyNi43OTk3ODQxLDIxLjU1Njc3NTkgTDI5LjY3NTIwODQsMjIuNjYwNTQ3OSBMMjguOTYxOTM1NiwyNC41MTg2ODcyIEwyNi4wOTg1NTE3LDIzLjQxOTUzNzEgQzI1Ljg3MzU5ODcsMjMuODI4ODI2IDI1LjYwOTIyNDgsMjQuMjEzMDczNSAyNS4zMTA1OTI0LDI0LjU2NzA3OTEgTDI3LjM2NTk4NjQsMjYuODQ5ODI1NCBMMjUuODg2ODc4LDI4LjE4MTYyMDYgTDIzLjgyNDc3MTQsMjUuODkxNDE5MSBDMjMuNDQ1Mzk3NywyNi4xNDI5NDcyIDIzLjA0MDE3MDgsMjYuMzU4MTMyMyAyMi42MTM5NzI3LDI2LjUzMjA1NjQgTDIzLjM1ODEzMTgsMjkuNTE2NzE1NCBMMjEuNDI2OTE2NiwyOS45OTgyMjE0IEwyMC42ODE3ODQ0LDI3LjAwOTY1OTQgQzIwLjQ1NzQ2NzgsMjcuMDMxNjA5MyAyMC4yMzAwMzYsMjcuMDQyODQxNiAyMCwyNy4wNDI4NDE2IEMxOS43Njk5NjQsMjcuMDQyODQxNiAxOS41NDI1MzIyLDI3LjAzMTYwOTMgMTkuMzE4MjE1NiwyNy4wMDk2NTk0IEwxOC41NzMwODM0LDI5Ljk5ODIyMTQgTDE2LjY0MTg2ODIsMjkuNTE2NzE1NCBMMTcuMzg2MDI3MywyNi41MzIwNTY0IEMxNi45NTk4MjkyLDI2LjM1ODEzMjMgMTYuNTU0NjAyMywyNi4xNDI5NDcyIDE2LjE3NTIyODYsMjUuODkxNDE5MSBMMTQuMTEzMTIyLDI4LjE4MTYyMDYgTDEyLjYzNDAxMzYsMjYuODQ5ODI1NCBMMTQuNjg5NDA3NiwyNC41NjcwNzkxIEMxNC4zOTA3NzUyLDI0LjIxMzA3MzUgMTQuMTI2NDAxMywyMy44Mjg4MjYgMTMuOTAxNDQ4MywyMy40MTk1MzcxIEwxMS4wMzgwNjQ0LDI0LjUxODY4NzIgTDEwLjMyNDc5MTYsMjIuNjYwNTQ3OSBMMTMuMjAwMjE1OSwyMS41NTY3NzU5IEMxMy4xMDE3MjQ1LDIxLjExMTA1NTYgMTMuMDQ1MzEzOCwyMC42NDkzNjI4IDEzLjAzNTQwMTMsMjAuMTc2MTQ3MyBMOS45ODE3NTc1OSwxOS44MDEyMDY5IEwxMC4yMjQzMTg2LDE3LjgyNTcwNTkgTDEzLjI3MTc5NzIsMTguMTk5ODg5MyBDMTMuMzkyNTEwNiwxNy43NDcyMTMgMTMuNTU3MDQxNiwxNy4zMTI2MTUgMTMuNzYwNTI4LDE2LjkwMDk5MzUgTDExLjIzMzU5NzgsMTUuMTMxNjE3OSBMMTIuMzc1MjA4LDEzLjUwMTIyOTYgTDE0Ljg4NjQwMTgsMTUuMjU5NTg2NCBDMTUuMTk5NDA5NywxNC45MTg5MDYzIDE1LjU0NTU0OCwxNC42MDk1NjU1IDE1LjkxOTY1OTMsMTQuMzM2NzU5NiBMMTQuNDc2MDk4NSwxMS42MjE4MTY1IEwxNi4yMzM0NjE0LDEwLjY4NzQxIEwxNy42NzkxOTEyLDEzLjQwNjQzMjIgWiBNMjAsMjMuMDMyNzYxMiBDMjEuNjQ4ODQ4OSwyMy4wMzI3NjEyIDIyLjk4NTUwNSwyMS42ODYyMzA2IDIyLjk4NTUwNSwyMC4wMjUyMDA5IEMyMi45ODU1MDUsMTguMzY0MTcxMyAyMS42NDg4NDg5LDE3LjAxNzY0MDYgMjAsMTcuMDE3NjQwNiBDMTguMzUxMTUxMSwxNy4wMTc2NDA2IDE3LjAxNDQ5NSwxOC4zNjQxNzEzIDE3LjAxNDQ5NSwyMC4wMjUyMDA5IEMxNy4wMTQ0OTUsMjEuNjg2MjMwNiAxOC4zNTExNTExLDIzLjAzMjc2MTIgMjAsMjMuMDMyNzYxMiBaIiBpZD0iT3ZhbC03LUNvcHktMiI+PC9wYXRoPiAgICAgICAgICAgIDwvZz4gICAgICAgIDwvZz4gICAgPC9nPjwvc3ZnPg==
ICON

    collector_name "rack_request"
    # collector_key  "rack_request"
    # collector_name "Request"
    position       2

    collect do |request, response|
      store :request_headers,   request.http_headers
      store :request_fullpath,  request.fullpath
      store :request_method,    request.request_method
      store :request_cookies,   request.cookies
      store :request_get,       request.GET
      store :request_post,      request_post(request)
      store :request_session,   hash_stringify_values(request.session)
      store :request_cookies,   request.cookies
      store :request_body,      request.body_string
      store :request_mediatype, request.media_type
      store :request_raw,       request.raw

      store :response_status,  response.status
      store :response_headers, response.headers
      store :response_raw,     response.raw

      if response.successful?
        status :success
      elsif response.redirection?
        status :warning
      else
        status :danger
      end
    end

    template __FILE__, type: :DATA

    class << self
      def request_post(request)
        request.POST if request.POST && !request.POST.empty?
      rescue Exception
        nil
      end

      def hash_stringify_values(hash)
        return {} unless hash.kind_of?(Hash)
        hash.collect {|k,v| [k, v.to_s]}
      end
    end
  end
end

__END__
<% tab_content do %>
  <%=h data(:response_status) %>

  <div class="details">
    <div class="wrapper">
      <dl>
        <dt>Status</dt>
        <dd><%=h data(:response_status) %> - <%=h Rack::Utils::HTTP_STATUS_CODES[data(:response_status).to_i] %></dd>
        <dt>Path</dt>
        <dd><%=h data(:request_method) %> <%=h data(:request_fullpath) %></dd>
      </dl>
    </div>
  </div>
<% end %>

<% panel_content do %>
  <div class="block">
    <h3>GET</h3>
    <% unless data(:request_get).empty? %>
    <table>
      <thead>
        <tr>
          <th>Key</th>
          <th>Value</th>
        </tr>
      <thead>
      <tbody>
      <% data(:request_get).each do |k, v| %>
        <tr>
          <th><%=h k %></th>
          <td class="code"><%=h v %></td>
        </tr>
      <% end %>
      </tbody>
    </table>
    <% else %>
    <p><span class="text__no-value">No GET parameters</span></p>
    <% end %>
  </div>

  <div class="block">
    <h3>POST</h3>
    <% if data(:request_post) && !data(:request_post).empty? %>
    <table>
      <thead>
        <tr>
          <th>Key</th>
          <th>Value</th>
        </tr>
      <thead>
      <tbody>
      <% data(:request_post).each do |k, v| %>
        <tr>
          <th><%=h k %></th>
          <td class="code"><%=h v %></td>
        </tr>
      <% end %>
      </tbody>
    </table>
    <% else %>
    <p><span class="text__no-value">No POST parameters</span></p>
    <% end %>
  </div>

  <div class="block">
    <h3>Request headers</h3>
    <% unless data(:request_headers).empty? %>
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Version</th>
        </tr>
      <thead>
      <tbody>
      <% data(:request_headers).sort.each do |k, v| %>
        <tr>
          <th><%=h k %></th>
          <td class="code"><%=h v %></td>
        </tr>
      <% end %>
      </tbody>
    </table>
    <% else %>
    <p><span class="text__no-value">No request headers</span></p>
    <% end %>
  </div>

  <div class="block">
    <h3>Request content</h3>
    <% unless data(:request_body).empty? %>
    <%=highlight mimetype: data(:request_mediatype), code: data(:request_body) %>
    <% else %>
    <p><span class="text__no-value">No request content</span></p>
    <% end %>
  </div>
  </div>

  <div class="block">
    <h3>Request raw</h3>
    <% unless data(:request_raw).nil? %>
    <%=highlight language: :http, code: data(:request_raw) %>
    <% else %>
    <p><span class="text__no-value">No request raw</span></p>
    <% end %>
  </div>

  <div class="block">
    <h3>Response headers</h3>
    <% unless data(:response_headers).empty? %>
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Version</th>
        </tr>
      <thead>
      <tbody>
      <% data(:response_headers).sort.each do |k, v| %>
        <tr>
          <th><%= k %></th>
          <td class="code"><%= v %></td>
        </tr>
      <% end %>
      </tbody>
    </table>
    <% else %>
    <p><span class="text__no-value">No response headers</span></p>
    <% end %>
  </div>

  <div class="block">
    <h3>Session</h3>
    <% unless data(:request_session).empty? %>
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Version</th>
        </tr>
      <thead>
      <tbody>
      <% data(:request_session).each do |k, v| %>
        <tr>
          <th><%= k %></th>
          <td class="code"><%= v %></td>
        </tr>
      <% end %>
      </tbody>
    </table>
    <% else %>
    <p><span class="text__no-value">No session data</span></p>
    <% end %>
  </div>

  <div class="block">
    <h3>Cookies</h3>
    <% unless data(:request_cookies).empty? %>
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Version</th>
        </tr>
      <thead>
      <tbody>
      <% data(:request_cookies).each do |k, v| %>
        <tr>
          <th><%=h k %></th>
          <td class="code"><%=h v %></td>
        </tr>
      <% end %>
      </tbody>
    </table>
    <% else %>
    <p><span class="text__no-value">No cookies data</span></p>
    <% end %>
  </div>
<% end %>
