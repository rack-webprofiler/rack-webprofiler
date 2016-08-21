require "erb"
require "json"

module Rack
  # Controller
  #
  # Generate the views of the WebProfiler.
  class WebProfiler::Controller
    # Initialize
    #
    # @param request [Rack::WebProfiler::Request]
    def initialize(request)
      @request      = request
      @contents_for = {}
    end

    # List the webprofiler history.
    #
    # @return [Rack::Response]
    def index
      @collections = Rack::WebProfiler::Model::CollectionRecord.order(Sequel.desc(:created_at))
                                                            .limit(20)

      if !@request.env["HTTP_ACCEPT"].nil? && @request.env["HTTP_ACCEPT"].include?("json")
        return json(@collections, 200, {only: [:token, :http_method, :http_status, :url, :ip]})
      end
      erb "panel/index.erb", layout: "panel/layout.erb"
    end

    # Show the webprofiler panel.
    #
    # @param token [String] The collection token
    #
    # @return [Rack::Response]
    def show(token)
      @collection = Rack::WebProfiler::Model::CollectionRecord[token: token]
      return error404 if @collection.nil?

      @collectors = Rack::WebProfiler.config.collectors.all
      @collector  = nil

      unless @request.params['panel'].nil?
        @collector = @collectors[@request.params['panel'].to_sym]
      end

      if @collector.nil?
        @collector = @collectors.values.first
      end

      @current_panel = @collector.name

      if !@request.env["HTTP_ACCEPT"].nil? && @request.env["HTTP_ACCEPT"].include?("json")
        return json(@collection)
      end
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
      # @todo process the callector views
      # @collectors = Rack::WebProfiler::Collector.render_tabs(@record)

      erb "profiler.erb"
    end

    # Clean the webprofiler.
    #
    # @return [Rack::Response]
    def delete
      Rack::WebProfiler::Model.clean

      redirect WebProfiler::Router.url_for_profiler
    end

    private

    def redirect(path)
      Rack::Response.new([], 302, {
        "Location" => "#{@request.base_url}#{path}",
      })
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
    def erb(path, layout: nil, variables: nil, status: 200)
      v = WebProfiler::View.new(path, layout: layout)

      variables ||= binding

      Rack::Response.new(v.result(variables), status, {
        "Content-Type" => "text/html",
      })
    end

    # Render a JSON response from an Array or a Hash.
    #
    # @param data [Array, Hash] Data
    # @param status [Integer]
    # @param opts [Hash]
    #
    # @return [Rack::Response]
    #
    # @private
    def json(data = {}, status = 200, opts = {})
      Rack::Response.new(data.send(:to_json, opts), status, {
        "Content-Type" => "application/json",
      })
    end

    def error404
      erb "404.erb", layout: "panel/layout.erb", status: 404
    end

    def _render_erb(template)
      ERB.new(template).result(binding)
    end

    def partial(path)
      return "" if path.nil?
      ERB.new(read_template(path)).result(binding)
    end

    def render_collector(collector, data)
      @data = data
      return "" if collector.nil?
      ERB.new(read_template(collector.template)).result(binding)
    end

    def content_for(name)
      name = name.to_sym

      if block_given?
        @contents_for[name] = Proc.new
      elsif @contents_for[name].respond_to?(:call)
        @contents_for[name].call
      end
    end

    def read_template(template)
      unless template.empty?
        path = ::File.expand_path("../../templates/#{template}", __FILE__)
        return ::File.read(path) if ::File.exist?(path)
      end
      template
    end
  end
end
