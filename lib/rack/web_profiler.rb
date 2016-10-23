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
    autoload :Response,   "rack/web_profiler/response"
    autoload :Request,    "rack/web_profiler/request"
    autoload :Router,     "rack/web_profiler/router"
    autoload :View,       "rack/web_profiler/view"

    module Rouge
      autoload :HTMLFormatter, "rack/web_profiler/rouge/html_formatter"
    end

    ENV_RUNTIME_START = 'rack_webprofiler.runtime_start'.freeze
    ENV_RUNTIME       = 'rack_webprofiler.runtime'.freeze
    ENV_EXCEPTION     = 'rack_webprofiler.exception'.freeze

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
    # @option tmp_dir [String]
    def initialize(app, tmp_dir: nil)
      @app = app

      WebProfiler.config.tmp_dir = tmp_dir unless tmp_dir.nil?
      WebProfiler.config(&Proc.new) if block_given?
    end

    # Call
    #
    # @param env [Hash]
    #
    # @return [Array]
    def call(env)
      begin
        request = WebProfiler::Request.new(env)
        env[ENV_RUNTIME_START] = Time.now.to_f

        response = WebProfiler::Router.response_for(request)
        return response.finish if response.is_a? Rack::Response

        status, headers, body = @app.call(env)
      rescue => e
        process(request, body, status, headers, e)
        raise
      end

      process(request, body, status, headers)
    end

    private

    # Process the request.
    #
    # @param request [Rack::WebProfiler::Request]
    # @param body
    # @param status [Integer]
    # @param headers [Hash]
    # @param exception [Exception, nil]
    #
    # @return [Rack::Response]
    def process(request, body, status, headers, exception = nil)
      request.env[ENV_RUNTIME]   = Time.now.to_f - request.env[ENV_RUNTIME_START]
      request.env[ENV_EXCEPTION] = nil

      unless exception.nil?
        request.env[ENV_EXCEPTION] = exception
        WebProfiler::Engine.process_exception(request).finish
      else
        WebProfiler::Engine.process(request, body, status, headers).finish
      end
    end
  end
end
