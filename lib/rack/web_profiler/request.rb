module Rack
  #
  class WebProfiler::Request < Rack::Request
    # Get HTTP headers.
    #
    # @return [Hash]
    def http_headers
      env.select { |k, _v| (k.start_with?("HTTP_") && k != "HTTP_VERSION") || k == "CONTENT_TYPE" }
        .collect { |k, v| [k.sub(/^HTTP_/, ""), v] }
        .collect { |k, v| [k.split("_").collect(&:capitalize).join("-"), v] }
    end

    # Get body has a String.
    #
    # @return [String]
    def body_string
      @body.to_s
    end

    # Get full HTTP request in HTTP format.
    #
    # @return [String]
    def raw
      headers = http_headers.map { |k, v| "#{k}: #{v}\r\n" }.join
      format "%s %s %s\r\n%s\r\n%s", request_method.upcase, fullpath, env["SERVER_PROTOCOL"], headers, body_string
    end

    def freeze # :nodoc:
      @body = body.read
      super
    end
  end
end
