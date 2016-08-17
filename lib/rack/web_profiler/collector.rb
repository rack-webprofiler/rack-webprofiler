require "docile"

module Rack

  # Collector
  class WebProfiler::Collector
    autoload :RubyCollector, "rack/web_profiler/collector/ruby_collector"
    autoload :TimeCollector, "rack/web_profiler/collector/time_collector"

    module Rack
      autoload :RackCollector,    "rack/web_profiler/collector/rack/rack_collector"
      autoload :RequestCollector, "rack/web_profiler/collector/rack/request_collector"
    end

    module Rails
      autoload :ActiveRecordCollector, "rack/web_profiler/collector/rails/active_record_collector"
      autoload :LoggerCollector,       "rack/web_profiler/collector/rails/logger_collector"
      autoload :RailsCollector,        "rack/web_profiler/collector/rails/rails_collector"
      autoload :RequestCollector,      "rack/web_profiler/collector/rails/request_collector"
    end

    module Sinatra
      autoload :RequestCollector, "rack/web_profiler/collector/sinatra/request_collector"
      autoload :SinatraCollector, "rack/web_profiler/collector/sinatra/sinatra_collector"
    end

    # DSL
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          @definition            = Definition.new
          @definition.position   = 1
          @definition.is_enabled = true
          @definition.klass      = self
        end
      end

      module ClassMethods
        attr_reader :definition

        def icon(icon = nil);           definition.icon     = icon;          end
        def collector_name(name = nil); definition.name     = name;          end
        def position(position = nil);   definition.position = position.to_i; end
        def collect(&block);            definition.collect  = block;         end

        def template(template = nil, type: :file)
          template = get_data_contents(template) if type == :DATA
          definition.template = template
        end

        def is_enabled?(is_enabled = true)
          definition.is_enabled = Proc.new if block_given?
          definition.is_enabled = is_enabled
        end

        private

        def get_data_contents(path)
          data = ""
          ::File.open(path, "rb") do |f|
            begin
              line = f.gets
            end until line.nil? || /^__END__$/ === line
            data << line while line = f.gets
          end
          data
        end
      end
    end

    # Definition
    #
    # Collector definition.
    class Definition
      attr_accessor :icon, :name, :position, :collect, :template, :is_enabled, :klass
      attr_reader   :data_storage

      # Collect the data who the Collector need.
      #
      # @param request [Rack::WebProfiler::Request]
      # @param response [Rack::Response]
      #
      # @return [Rack::WebProfiler::Collector::DSL::DataStorage]
      def collect!(request, response)
        @data_storage = Docile.dsl_eval(DataStorage.new, request, response, &collect)
      end

      # Is the collector enabled.
      #
      # @return [Boolean]
      def is_enabled?
        return !!@is_enabled.call if @is_enabled.is_a?(Proc)
        !!@is_enabled
      end
    end

    # DataStorage
    #
    # Used to store datas who Collector needs.
    #
    # @todo do DataStorage compatible with Marshal
    class DataStorage
      attr_reader :datas

      def initialize
        @datas  = Hash.new
        @status = nil
      end

      # Store a value.
      #
      # @param k [String, Symbol]
      # @param v
      def store(k, v)
        # @todo check data format (must be compatible with Marshal)
        @datas[k.to_sym] = v
      end

      # Status.
      #
      # @param v [Symbol, nil]
      #
      # @return [Symbol, nil]
      def status(v = nil)
        # @todo check status?
        # raise Exception, "" unless [:success, :warning, :error].include?(v)
        @status = v.to_sym unless v.nil?
        @status
      end

      # Transform DataStorage to an Hash
      #
      # @return [Hash<Symbol, Object>]
      def to_h
        {
          datas: @datas,
          status: @status
        }
      end
    end
  end
end
