module Rack
  class WebProfiler::Collector::DebugCollector
    include Rack::WebProfiler::Collector::DSL

    icon nil

    collector_name "debug"
    position       1

    collect do |request, response|
      store :key,       "value"
      store :backtrace, "value"
    end

    template __FILE__, type: :DATA
  end
end

# # @see also https://gist.github.com/ubermajestix/3644301
# module Object
#   def inspect
#     res = super
#     # save the res on collector storage
#     res
#   end
# end

__END__
<% content_for :tab do %>
  <%= data[:ruby_version] %>
<% end %>
