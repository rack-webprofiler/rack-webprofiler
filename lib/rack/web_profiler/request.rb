module Rack
  #
  class WebProfiler::Request < Rack::Request
    attr_reader :runtime

    def start_runtime!
      @request_start ||= Time.now.to_f
    end

    def save_runtime!
      @runtime ||= Time.now.to_f - @request_start
    end
  end
end
