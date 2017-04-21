module Rack
  #
  class WebProfiler::Engine
    class << self
      # Process request.
      #
      # @param request [Rack::WebProfiler::Request]
      # @param body [Array, String]
      # @param status [Integer]
      # @param headers [Hash]
      #
      # @return [Rack::WebProfiler::Response, Rack::Response]
      def process(request, body, status, headers)
        response = Rack::WebProfiler::Response.new(request, body, status, headers)
        record   = collect!(request, response)

        @token = record.token
        @url   = WebProfiler::Router.url_for_toolbar(record.token)

        response.header["X-RackWebProfiler-Token"] = @token
        response.header["X-RackWebProfiler-Url"]   = WebProfiler::Router.url_for_profiler(record.token)

        return response if !headers[CONTENT_TYPE].nil? and !headers[CONTENT_TYPE].include? "text/html"

        response = Rack::Response.new([], status, response.headers)

        if body.respond_to?(:each)
          body.each { |fragment| response.write inject(fragment) }
        elsif body.is_a? String
          response.write inject(body)
        end

        response
      end

      # Process an exception.
      #
      # @param request [Rack::WebProfiler::Request]
      #
      # @return [Rack::Response]
      def process_exception(request)
        process(request, [], 500, {})
      end

      private

      # Collect
      #
      # @param request [Rack::WebProfiler::Request]
      # @param response [Rack::Response]
      #
      # @return [WebProfiler::Model::CollectionRecord]
      def collect!(request, response)
        processor = Processor.new(request.clone.freeze, response.clone.freeze)
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
        @template ||= WebProfiler::View.new("async.erb")
      end

      class Processor
        attr_reader :record

        def initialize(request, response)
          @record = new_record(request, response)
        end

        def save!
          @record.save({ transaction: true })
        rescue => e
          # @todo raise_if_debug WebProfiler::RuntimeError, "Error while processing to save datas", e.backtrace
        end

        private

        def new_record(request, response)
          WebProfiler::Model::CollectionRecord.new({
            url:          request.url,
            ip:           request.ip,
            http_method:  request.request_method,
            http_status:  response.status,
            content_type: response.content_type,
            datas:        collect_datas(request, response),
          })
        end

        def collect_datas(request, response)
          datas = {}

          Rack::WebProfiler.config.collectors.all.each do |name, definition|
            begin
              datas[name.to_sym] = definition.collect!(request, response).to_h
            rescue => e
              # @todo raise_if_debug WebProfiler::RuntimeError, "Error while collecting datas of collector '#{name}'"
            end
          end

          datas
        end
      end
    end
  end
end
