module Rack
  # Router
  #
  # Show WebProfiler page if the request path match with one
  # of the webprofiler routes.
  class WebProfiler::Router
    BASE_PATH = "/_rwpt".freeze

    class << self
      # Get response for given request.
      #
      # @param request [Rack::WebProfiler::Request]
      #
      # @return [Rack::Reponse, false]
      def response_for(request)
        @request = request
        path     = Rack::Utils.unescape(request.path_info)

        # Stop process if the request path does not start
        # by the BASE_PATH.
        return false unless path.start_with?(BASE_PATH)

        path.slice!(BASE_PATH)

        route(request, path)
      end

      # Route the request.
      #
      # @param request [Rack::WebProfiler::Request]
      # @param path [String]
      #
      # @return [Rack::Reponse, false]
      def route(request, path)
        controller = WebProfiler::Controller.new(request)

        if request.get? && path =~ %r{^\/assets\/(.*)(\/)?$}
          serve_asset(Regexp.last_match(1))
        elsif request.get? && path =~ %r{^\/toolbar\/([a-z0-9]*)(\/)?$}
          controller.show_toolbar(Regexp.last_match(1))
        elsif request.get? && path =~ %r{^\/clean(\/)?$}
          controller.delete
        elsif request.get? && path =~ %r{^(\/)?$}
          controller.index
        elsif request.get? && path =~ %r{^\/([a-z0-9]*)(\/)?$}
          controller.show(Regexp.last_match(1))
        else
          false
        end
      end

      # Serve assets.
      #
      # @param path [String]
      #
      # @return [Rack::Response]
      def serve_asset(path)
        rf = Rack::File.new(::File.expand_path("../../templates/assets/", __FILE__))
        request = @request.dup
        request.env[PATH_INFO] = "/#{path}"


        status, headers, body = rf.call(request.env)
        Rack::Response.new(body, status, headers)
      end

      # Get url for asset.
      #
      # @param path [String]
      #
      # @return [String]
      def url_for_asset(path)
        "#{get_base_path}/assets/#{path}"
      end

      # Get url for toobar.
      #
      # @param token [String]
      #
      # @return [String]
      def url_for_toolbar(token)
        "#{get_base_path}/toolbar/#{token}"
      end

      # Get url for the webprofiler.
      #
      # @param token [String, nil]
      # @param panel [String, nil]
      #
      # @return [String]
      def url_for_profiler(token = nil, panel = nil)
        query = ""
        query = "?panel=#{panel}" unless panel.nil?
        "#{get_base_path}/#{token}#{query}"
      end

      # Get url to clean webprofiler.
      #
      # @return [String]
      def url_for_clean_profiler
        "#{get_base_path}/clean"
      end

      private

      def get_base_path
        "#{@request.env["ORIGINAL_SCRIPT_NAME"]}#{BASE_PATH}"
      end
    end
  end
end
