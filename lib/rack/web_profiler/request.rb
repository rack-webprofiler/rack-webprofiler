module Rack
  #
  class WebProfiler::Request < Rack::Request
    attr_reader :runtime, :exception

    def start_runtime!
      @request_start ||= Time.now.to_f
    end

    def save_runtime!
      @runtime ||= Time.now.to_f - @request_start
    end

    def save_exception(e)
      @exception = e
    end
  end
end
