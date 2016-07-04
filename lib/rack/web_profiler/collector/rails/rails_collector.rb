module Rack
  class WebProfiler::Collector::Rails::RailsCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "rails"
    position       1

    collect do |_request, _response|
      store :rails_version, Rails.version
      store :rails_env,     Rails.env
      store :rails_doc_url, "http://api.rubyonrails.org/v#{Rails.version}/"
    end

    template __FILE__, type: :DATA

    is_enabled? -> { defined? Rails }
  end
end

__END__
<%# content_for :tab do %>
  <%= data[:rails_version] %> | <%= data[:rails_env] %>
<%# end %>
