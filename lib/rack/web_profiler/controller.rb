require "erb"
require "json"

module Rack
  class WebProfiler
    # Controller
    #
    # Generate the views of the WebProfiler.
    class Controller
      # Initialize.
      #
      # @param request [Rack::WebProfiler::Request]
      def initialize(request)
        @request = request
      end

      # List the webprofiler history.
      #
      # @return [Rack::Response]
      def index
        @collections = Rack::WebProfiler::Model::CollectionRecord.order(Sequel.desc(:created_at))
          .limit(20)

        return json(@collections, to_json_opts: {
          only: [:token, :http_method, :http_status, :url, :ip]
        }) if prefer_json?

        erb "panel/index.erb", layout: "panel/layout.erb"
      end

      # Show the webprofiler panel.
      #
      # @param token [String] The collection token
      #
      # @return [Rack::Response]
      def show(token)
        @collection = Rack::WebProfiler::Model::CollectionRecord[token: token]
        return not_found if @collection.nil?

        @collectors = Rack::WebProfiler.config.collectors.all
        @collector  = nil

        unless @request.params["panel"].nil?
          @collector = @collectors[@request.params["panel"].to_sym]
        else
          @collector = @collectors.values.first
        end

        return not_found if @collector.nil?

        return json(@collection) if prefer_json?
        erb "panel/show.erb", layout: "panel/layout.erb"
      end

      # Print the webprofiler toolbar.
      #
      # @param token [String] The collection token
      #
      # @return [Rack::Response]
      def show_toolbar(token)
        @collection = Rack::WebProfiler::Model::CollectionRecord[token: token]
        return erb nil, status: 404 if @collection.nil?

        @collectors = Rack::WebProfiler.config.collectors.all

        erb "profiler.erb"
      end

      # Clean the webprofiler.
      #
      # @return [Rack::Response]
      def delete
        Rack::WebProfiler::Model.clean!

        redirect WebProfiler::Router.url_for_profiler
      end

      private

      # Is "application/json" reponse is prefered?
      #
      # @return [Boolean]
      #
      # @private
      def prefer_json?
        prefered_http_accept == "application/json"
      end

      # Returns the prefered Content-Type response between html and json.
      #
      # @return [String]
      #
      # @private
      def prefered_http_accept
        Rack::Utils.best_q_match(@request.env["HTTP_ACCEPT"], %w(text/html application/json))
      end

      # Redirection.
      #
      # @param path [string]
      #
      # @return [Rack::Response]
      #
      # @private
      def redirect(path)
        Rack::Response.new([], 302, {
          "Location" => "#{@request.base_url}#{path}",
        })
      end

      # 404 page.
      #
      # @return [Rack::Response]
      #
      # @private
      def not_found
        erb "404.erb", layout: "panel/layout.erb", status: 404
      end

      # Render a HTML reponse from an ERB template.
      #
      # @param path [String] Path to the ERB template
      # @option layout [String, nil] Path to the ERB layout
      # @option variables [Hash, nil] List of variables to the view
      # @option status [Integer] HTTP status code
      #
      # @return [Rack::Response]
      #
      # @private
      def erb(path, layout: nil, variables: binding, status: 200)
        v = WebProfiler::View.new(path, layout: layout)

        Rack::Response.new(v.result(variables) || "", status, {
          "Content-Type" => "text/html",
        })
      end

      # Render a JSON response from an Array or a Hash.
      #
      # @param data [Array, Hash] Data
      # @option status [Integer]
      # @option to_json_opts [Hash]
      #
      # @return [Rack::Response]
      #
      # @private
      def json(data = {}, status: 200, to_json_opts: {})
        Rack::Response.new(data.send(:to_json, to_json_opts), status, {
          "Content-Type" => "application/json",
        })
      end
    end
  end
end
