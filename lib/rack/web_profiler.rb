require "rack"

module Rack
  # WebProfiler
  class WebProfiler
    autoload :VERSION,    "rack/web_profiler/version"
    autoload :Config,     "rack/web_profiler/config"
    autoload :Collector,  "rack/web_profiler/collector"
    autoload :Collectors, "rack/web_profiler/collectors"
    autoload :Controller, "rack/web_profiler/controller"
    autoload :Engine,     "rack/web_profiler/engine"
    autoload :Model,      "rack/web_profiler/model"
    autoload :Request,    "rack/web_profiler/request"
    autoload :Router,     "rack/web_profiler/router"

    module AutoConfigure
      autoload :Rails, "rack/web_profiler/auto_configure/rails"
    end

    class << self
      def config
        @config ||= Config.new
        @config.build!(&Proc.new) if block_given?
        @config
      end

      def register_collector(collector_class)
        config.collectors.add_collector collector_class
      end

      def unregister_collector(collector_class)
        config.collectors.remove_collector collector_class
      end
    end

    # Initialize
    #
    # @param app [Proc]
    def initialize(app, tmp_dir: nil)
      @app = app
      # WebProfiler.config(&Proc.new) if block_given?
      WebProfiler.config.tmp_dir = tmp_dir unless tmp_dir.nil?
    end

    # Call
    #
    # @param env [Hash]
    #
    # @return [Array]
    def call(env)
      begin
        request = WebProfiler::Request.new(env)
        request.start_runtime!

        response = WebProfiler::Router.response_for(request)
        return response.finish if response.is_a? Rack::Response

        status, headers, body = @app.call(env)
      rescue Exception => e
        process(request, body, status, headers, e)
        raise e
      end

      process(request, body, status, headers)
    end

    private

    def process(request, body, status, headers, exception = nil)
      request.save_runtime!

      unless exception.nil?
        request.save_exception(exception)
        WebProfiler::Engine.process_exception(request).finish
      else
        WebProfiler::Engine.process(request, body, status, headers).finish
      end
    end
  end
end

require "rack/web_profiler/auto_configure/rails" if defined? Rails
