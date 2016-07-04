module Rack
  class WebProfiler::Collector::RubyCollector
    include Rack::WebProfiler::Collector::DSL

    icon <<-'ICON'
data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB1ElEQVR4XqWTTWsTURSGn3tnpqJYbbKImjaV1IVEgwqpYKNuxK0tRCku/MK/oOBv8L904we4r+10Y0FdWEKsVrAZic2kxDZNwkyOlw51cDal9IXDGYZ5nvfexSgR4TBRxMHNIYMQBEBFozTRjoepb6ikgIUzyIV7T0mVbgGAV4f1ddAWvQ2Pthlt2bTbdX7Vv1D+HrF6Dy5UHpMqlqHzB/wGfK1Cf8dMhyMjaZRlEQQ9jg+fJpMt4OYRAO2Omea7T0gXr0O3A2EAtRoAiMAg3H2Xzo4TmudAQoZPZMmMXsSdQNRiFim/rcLWJqYCbAvm5sBxQCuA6OK2A+9eRVtp0EMsNeaxlQ2tl89InS1C0I8+rlWjrXUsMNBat4u2A7SBOoFHCE0FlBbG+FC4eYd0/goMAvA8aLYiQSQyB/TxfzewtMN24NPs/aC8ymUNLN/4yeTK+zf4a5/AGYLMKRD+a2/7LQOb5hieBD5rgH+S+df4qx/h6DEYOblnoLe9xSAMd5s3YniZZKLrIM0HMyLPX4hMV0Qqs9K4OiXVQk7ccwhQIhmSkpyRPDTw/UciM7Oycn5U3IkEvK9kHNmcvi31a5dkMX8gOJa4BlxKNB9Ysh986N/5L2oi0DPAz3KGAAAAAElFTkSuQmCC
ICON

    collector_name "ruby"
    position       0

    collect do |_request, _response|
      store :ruby_version,      RUBY_VERSION
      store :ruby_release_date, RUBY_RELEASE_DATE
      store :ruby_platform,     RUBY_PLATFORM
      # store :gems_list,         Gem.loaded_specs.values
      store :ruby_doc_url,      "http://www.ruby-doc.org/core-#{RUBY_VERSION}/"
    end

    template __FILE__, type: :DATA
  end
end

__END__
<%# content_for :tab do %>
  <%= data[:ruby_version] %>
<%# end %>
