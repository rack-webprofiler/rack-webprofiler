module Rack

  # Collectors.
  #
  # Container of Collector objects.
  class WebProfiler::Collectors

    # Initialize.
    def initialize
      @collectors        = {}
      @sorted_collectors = {}
    end

    # Get a collector definition by his name.
    #
    # @param name [String]
    #
    # @return [Rack::WebProfiler::Collector::DSL::Definition, nil]
    def definition_by_name(name)
      name = name.to_sym
      @sorted_collectors[name] unless @sorted_collectors[name].nil?
    end

    # Returns all collectors definition.
    #
    # @return [Hash<Symbol, Rack::WebProfiler::Collector::DSL::Definition>]
    def all
      @sorted_collectors
    end

    # Add a collector.
    #
    # @param collector_class [Class]
    #
    # @raise [ArgumentError] if `collector_class' is not a Class or is not an instance of Rack::WebProfiler::Collector::DSL
    #   or a collector with this name is already registrered.
    def add_collector(collector_class)
      unless collector_class.is_a? Class
        raise ArgumentError, "`collector_class' must be a class"
      end

      unless collector_class.included_modules.include?(Rack::WebProfiler::Collector::DSL)
        raise ArgumentError, "#{collector_class.class.name} must be an instance of \"Rack::WebProfiler::Collector::DSL\""
      end

      definition = collector_class.definition

      if definition_by_name(definition.name)
        raise ArgumentError, "A collector with name \“#{definition.name}\" already exists"
      end

      return false unless definition.is_enabled?

      @collectors[collector_class] = definition

      sort_collectors!
    end

    # Remove a collector.
    #
    # @param collector_class [Class]
    #
    # @raise [ArgumentError] if `collector_class' is not a Class or if this collector is not registered.
    def remove_collector(collector_class)
      unless collector_class.is_a? Class
        raise ArgumentError, "`collector_class' must be a class"
      end

      unless @collectors[collector_class]
        raise ArgumentError, "No collector found with class \“#{collector_class}\""
      end

      @collectors.delete(collector_class)

      sort_collectors!
    end

    private

    # Sort collectors by definition name.
    def sort_collectors!
      @sorted_collectors = {}

      tmp = @collectors.sort_by { |_klass, definition| definition.position }
      tmp.each { |_k, v| @sorted_collectors[v.name.to_sym] = v }
    end
  end
end
