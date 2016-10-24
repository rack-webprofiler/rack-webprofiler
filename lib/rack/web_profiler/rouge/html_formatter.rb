module Rack
  #
  class WebProfiler::Rouge::HTMLFormatter < ::Rouge::Formatter

    # Initialize the Formatter.
    #
    # @param request [Hash]
    def initialize(opts = {})
      @formatter = opts[:inline_theme] \
        ? ::Rouge::Formatters::HTMLInline.new(opts[:inline_theme])
        : ::Rouge::Formatters::HTML.new

      if opts[:line_numbers]
        @formatter = ::Rouge::Formatters::HTMLTable.new(@formatter, opts)
      else
        @formatter = ::Rouge::Formatters::HTMLPygments.new(@formatter)
      end
    end

    # @yield the html output.
    def stream(tokens, &b)
      @formatter.stream(tokens, &b)
    end
  end
end
