module Rack
  # Collectors.
  #
  # Container of Collector objects.
  class WebProfiler::Collectors
    # Collectors
    autoload :RackCollector,      "rack/web_profiler/collectors/rack_collector"
    autoload :RequestCollector,   "rack/web_profiler/collectors/request_collector"
    autoload :RubyCollector,      "rack/web_profiler/collectors/ruby_collector"
    autoload :TimeCollector,      "rack/web_profiler/collectors/time_collector"

    # Initialize.
    def initialize
      reset!
    end

    # Get a collector definition by his identifier.
    #
    # @param identifier [String]
    #
    # @return [Rack::WebProfiler::Collector::DSL::Definition, nil]
    def definition_by_identifier(identifier)
      identifier = identifier.to_sym
      @sorted_collectors[identifier] unless @sorted_collectors[identifier].nil?
    end

    # Returns all collectors definition.
    #
    # @return [Hash<Symbol, Rack::WebProfiler::Collector::DSL::Definition>]
    def all
      @sorted_collectors
    end

    # Add a collector.
    #
    # @param collector_class [Array, Class]
    #
    # @raise [ArgumentError] if `collector_class' is not a Class or is not an instance of Rack::WebProfiler::Collector::DSL
    #   or a collector with this identifier is already registrered.
    def add_collector(collector_class)
      return collector_class.each { |c| add_collector(c) } if collector_class.is_a? Array


      raise ArgumentError, "`collector_class' must be a class" unless collector_class.is_a? Class

      unless collector_class.included_modules.include?(Rack::WebProfiler::Collector::DSL)
        raise ArgumentError, "#{collector_class.class.name} must be an instance of \"Rack::WebProfiler::Collector::DSL\""
      end

      definition = collector_class.definition

      if definition_by_identifier(definition.identifier)
        raise ArgumentError, "A collector with identifier \“#{definition.identifier}\" already exists"
      end

      return false unless definition.is_enabled?

      @collectors[collector_class] = definition

      sort_collectors!
    end

    # Remove a collector.
    #
    # @param collector_class [Array, Class]
    #
    # @raise [ArgumentError] if `collector_class' is not a Class or if this collector is not registered.
    def remove_collector(collector_class)
      return collector_class.each { |c| remove_collector(c) } if collector_class.is_a? Array

      raise ArgumentError, "`collector_class' must be a class" unless collector_class.is_a? Class
      raise ArgumentError, "No collector found with class \“#{collector_class}\"" unless @collectors[collector_class]

      @collectors.delete(collector_class)

      sort_collectors!
    end

    # Reset collecotrs.
    def reset!
      @collectors        = {}
      @sorted_collectors = {}
    end

    private

    # Sort collectors by definition identifier.
    def sort_collectors!
      @sorted_collectors = {}

      tmp = @collectors.sort_by { |_klass, definition| definition.position }
      tmp.each { |_k, v| @sorted_collectors[v.identifier.to_sym] = v }
    end
  end
end
