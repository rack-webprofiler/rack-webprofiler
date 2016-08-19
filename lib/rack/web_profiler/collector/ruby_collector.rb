module Rack
  class WebProfiler::Collector::RubyCollector
    include Rack::WebProfiler::Collector::DSL

    icon <<-'ICON'
data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PHN2ZyB3aWR0aD0iMjBweCIgaGVpZ2h0PSIyMHB4IiB2aWV3Qm94PSIwIDAgMjAgMjAiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+ICAgICAgICA8dGl0bGU+VHJpYW5nbGUgMTwvdGl0bGU+ICAgIDxkZXNjPkNyZWF0ZWQgd2l0aCBTa2V0Y2guPC9kZXNjPiAgICA8ZGVmcz48L2RlZnM+ICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPiAgICAgICAgPGcgaWQ9IkRlc2t0b3AtMiIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTcxLjAwMDAwMCwgLTEwLjAwMDAwMCkiIGZpbGw9IiM1ODU0NzMiPiAgICAgICAgICAgIDxwYXRoIGQ9Ik04MSwzMCBMNzEsMTUgTDkxLDE1IEw4MSwzMCBaIE05MSwxNCBMNzEsMTQgTDc1LDEwIEw4NywxMCBMOTEsMTQgWiIgaWQ9IlRyaWFuZ2xlLTEiPjwvcGF0aD4gICAgICAgIDwvZz4gICAgPC9nPjwvc3ZnPg==
ICON

    collector_name "ruby"
    position       0

    collect do |_request, _response|
      store :ruby_version,      RUBY_VERSION
      store :ruby_patchlevel,   RUBY_PATCHLEVEL
      store :ruby_release_date, RUBY_RELEASE_DATE
      store :ruby_platform,     RUBY_PLATFORM
      store :ruby_revision,     RUBY_REVISION
      store :gems_list,         gems_list
      store :ruby_doc_url,      "http://www.ruby-doc.org/core-#{RUBY_VERSION}/"
    end

    template __FILE__, type: :DATA

    class << self
      def gems_list
        gems = []

        Gem.loaded_specs.values.each do |g|
          gems << {
            name:     g.name,
            version:  g.version.to_s,
            homepage: g.homepage,
            summary:  g.summary,
          }
        end

        gems
      end
    end
  end
end

__END__
<% content_for :tab do %>
  <%= data[:ruby_version] %>
<% end %>

<% content_for :panel do %>
  <div class="block">
    <h3>Ruby informations</h3>
    <table>
      <tr>
        <th>Version</th>
        <td><%= "#{data[:ruby_version]}p#{data[:ruby_patchlevel]} (#{data[:ruby_release_date]} revision #{data[:ruby_revision]}) [#{data[:ruby_platform]}]" %></td>
      </tr>
      <tr>
        <th>Documentation</th>
        <td><a href="<%= data[:ruby_doc_url] %>"><%= data[:ruby_doc_url] %></a></td>
      </tr>
    </table>
  </div>

  <div class="block">
    <h3>Gems</h3>
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Version</th>
        </tr>
      <thead>
      <tbody>
      <% data[:gems_list].sort!{|a,b| a[:name] <=> b[:name] }.each do |g| %>
        <tr>
          <th><%= g[:name] %></th>
          <td><%= g[:version] %></td>
        </tr>
      <% end %>
      </tbody>
    </table>
  </div>
<% end %>
