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
        # by the BASE_PATH
        return false unless path.start_with?(BASE_PATH)

        path.slice!(BASE_PATH)

        route(request, path)
      end

      # Route!
      def route(request, path)
        controller = WebProfiler::Controller.new(request)

        if request.get? && path =~ %r{^\/toolbar\/([a-z0-9]*)(\/)?$}
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

      # Get url for toobar.
      #
      # @param token [String]
      #
      # @return [String]
      def url_for_toolbar(token)
        "#{@request.script_name}#{BASE_PATH}/toolbar/#{token}"
      end

      # Get url for the webprofiler.
      #
      # @param token [String, nil]
      #
      # @return [String]
      def url_for_profiler(token = nil)
        "#{@request.script_name}#{BASE_PATH}/#{token}"
      end

      # Get url to clean webprofiler.
      #
      # @param token [String, nil]
      #
      # @return [String]
      def url_for_clean_profiler
        "#{@request.script_name}#{BASE_PATH}/clean"
      end
    end
  end
end
