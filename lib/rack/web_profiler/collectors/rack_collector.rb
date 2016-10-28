module Rack
  class WebProfiler::Collectors::RackCollector
    include Rack::WebProfiler::Collector::DSL

    icon <<-'ICON'
data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PHN2ZyB3aWR0aD0iMjJweCIgaGVpZ2h0PSIyMnB4IiB2aWV3Qm94PSIwIDAgMjIgMjIiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+ICAgICAgICA8dGl0bGU+R3JvdXA8L3RpdGxlPiAgICA8ZGVzYz5DcmVhdGVkIHdpdGggU2tldGNoLjwvZGVzYz4gICAgPGRlZnM+PC9kZWZzPiAgICA8ZyBpZD0iUGFnZS0xIiBzdHJva2U9Im5vbmUiIHN0cm9rZS13aWR0aD0iMSIgZmlsbD0ibm9uZSIgZmlsbC1ydWxlPSJldmVub2RkIj4gICAgICAgIDxnIGlkPSJEZXYtYmFyLSstRHJvcCIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTkuMDAwMDAwLCAtMTc2LjAwMDAwMCkiIHN0cm9rZT0iIzQ1NDI1QSI+ICAgICAgICAgICAgPGcgaWQ9Ikdyb3VwIiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgxMC4wMDAwMDAsIDE3Ny4wMDAwMDApIj4gICAgICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlJlY3RhbmdsZS0yNzgiIHBvaW50cz0iMCA0IDYgMCAyMCA1IDIwIDE2IDE0IDIwIDAgMTUiPjwvcG9seWdvbj4gICAgICAgICAgICAgICAgPHBhdGggZD0iTTE1Ljg2Njg2Miw4LjUxMzUwOTA5IEwyMCwxMCIgaWQ9IlJlY3RhbmdsZS0yNzgtQ29weS04Ij48L3BhdGg+ICAgICAgICAgICAgICAgIDxwYXRoIGQ9Ik0xNS44NjY4NjIsMTMuNTEzNTA5MSBMMjAsMTUiIGlkPSJSZWN0YW5nbGUtMjc4LUNvcHktOSI+PC9wYXRoPiAgICAgICAgICAgICAgICA8cGF0aCBkPSJNMCw5IEw1LDYiIGlkPSJSZWN0YW5nbGUtMjc4LUNvcHktNiI+PC9wYXRoPiAgICAgICAgICAgICAgICA8cGF0aCBkPSJNMTQsOSBMMTQsMTkuNTExODk4IiBpZD0iTGluZSIgc3Ryb2tlLWxpbmVjYXA9InNxdWFyZSI+PC9wYXRoPiAgICAgICAgICAgICAgICA8cGF0aCBkPSJNMCwxNCBMNSwxMSIgaWQ9IlJlY3RhbmdsZS0yNzgtQ29weS03Ij48L3BhdGg+ICAgICAgICAgICAgICAgIDxwb2x5bGluZSBpZD0iUmVjdGFuZ2xlLTI3OC1Db3B5IiBwb2ludHM9IjIwIDUgMTQgOSAwIDQiPjwvcG9seWxpbmU+ICAgICAgICAgICAgICAgIDxwb2x5bGluZSBpZD0iUmVjdGFuZ2xlLTI3OC1Db3B5LTIiIHBvaW50cz0iMjAgMTUgMTQgMTkgMCAxNCI+PC9wb2x5bGluZT4gICAgICAgICAgICAgICAgPHBvbHlsaW5lIGlkPSJSZWN0YW5nbGUtMjc4LUNvcHktNCIgcG9pbnRzPSIyMCAxMSAxNCAxNSAwIDEwIj48L3BvbHlsaW5lPiAgICAgICAgICAgICAgICA8cG9seWxpbmUgaWQ9IlJlY3RhbmdsZS0yNzgtQ29weS01IiBwb2ludHM9IjIwIDEwIDE0IDE0IDAgOSI+PC9wb2x5bGluZT4gICAgICAgICAgICAgICAgPHBvbHlsaW5lIGlkPSJSZWN0YW5nbGUtMjc4LUNvcHktMyIgcG9pbnRzPSIyMCA2IDE0IDEwIDAgNSI+PC9wb2x5bGluZT4gICAgICAgICAgICA8L2c+ICAgICAgICA8L2c+ICAgIDwvZz48L3N2Zz4=
ICON

    identifier "rack"
    label      "Rack"
    position   1

    collect do |request, _response|
      store :rack_version, Rack.release
      store :rack_env,     hash_stringify_values(request.env)
    end

    template __FILE__, type: :DATA

    class << self
      def hash_stringify_values(hash)
        return {} unless hash.kind_of?(Hash)
        hash.collect do |k,v|
          v = v.inspect unless v.kind_of?(String)
          [k, v]
        end
      end
    end
  end
end

__END__
<% tab_content do %>
  <%=h data(:rack_version) %>
<% end %>

<% panel_content do %>
  <div class="block">
    <h3>Env</h3>
    <% if data(:rack_env) && !data(:rack_env).empty? %>
    <table>
      <thead>
        <tr>
          <th>Key</th>
          <th>Value</th>
        </tr>
      <thead>
      <tbody>
      <% data(:rack_env).sort.each do |k, v| %>
        <tr>
          <th><%=h k %></th>
          <td class="code"><%=h v %></td>
        </tr>
      <% end %>
      </tbody>
    </table>
    <% else %>
    <p><span class="text__no-value">No rack env datas</span></p>
    <% end %>
  </div>
<% end %>
