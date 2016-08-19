module Rack
  #
  class WebProfiler::Engine
    class << self
      # Process
      #
      # @param request [Rack::WebProfiler::Request]
      # @param body
      # @param status
      # @param headers
      #
      # @return [Rack::Response]
      def process(request, body, status, headers)
        response = Rack::Response.new(body, status, headers)
        record   = collect!(request, response)

        return response if !headers[CONTENT_TYPE].nil? and !headers[CONTENT_TYPE].include? "text/html"

        @token = record.token
        @url   = WebProfiler::Router.url_for_toolbar(record.token)

        response = Rack::Response.new([], status, headers)

        response.header["X-RackWebProfiler-Token"] = @token
        response.header["X-RackWebProfiler-Url"]   = @url

        if defined? Rails and body.is_a? ActionDispatch::Response::RackBody
          body = body.body
        end

        if body.is_a? Array
          body.each { |fragment| response.write inject(fragment) }
        elsif body.is_a? String
          response.write inject(body)
        end

        response
      end

      def process_exception(request)
        process(request, [], 500, {})
      end

      private

      # Collect
      #
      # @param request
      # @param response
      def collect!(request, response)
        processor = Processor.new(request, response)
        processor.save!

        processor.record
      end

      # Inject the webprofiler
      #
      # @param body [String]
      def inject(body)
        body.gsub(%r{</body>}, template.result(binding) + "</body>")
      end

      # Get the javascript code template to inject.
      #
      # @return [String]
      def template
        @template ||= ERB.new(::File.read(::File.expand_path("../../templates/async.erb", __FILE__)))
      end

      class Processor
        attr_reader :record

        def initialize(request, response)
          @collectors = {}
          @request    = request.clone.freeze
          @response   = response.clone.freeze
          @record     = nil
        end

        def save!
          create_record!
          save_collected_datas!

          @record.save
        end

        private

        def create_record!
          @record ||= WebProfiler::Model::CollectionRecord.create({
            url:           @request.path,
            ip:            @request.ip,
            http_method:   @request.request_method,
            http_status:   @response.status,
            content_type:  @response.content_type,
            datas:         {},
          })
        end

        def save_collected_datas!
          datas = {}

          Rack::WebProfiler.config.collectors.all.each do |name, definition|
            datas[name.to_sym] = definition.collect!(@request, @response).to_h
          end

          @record.datas = datas
        end
      end
    end
  end
end
