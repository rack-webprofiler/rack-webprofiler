require "fileutils"
require "tmpdir"

module Rack
  # Config
  class WebProfiler::Config
    attr_accessor :collectors, :tmp_dir

    DEFAULT_COLLECTORS = [
      Rack::WebProfiler::Collectors::RackCollector,
      Rack::WebProfiler::Collectors::RequestCollector,
      Rack::WebProfiler::Collectors::RubyCollector,
      Rack::WebProfiler::Collectors::TimeCollector,
    ].freeze

    # Initialize Config.
    def initialize
      @collectors = Rack::WebProfiler::Collectors.new

      load_defaults!
    end

    # Setup the configuration
    def build!
      unless block_given?
        # @todo raise an Exception if no block given
      end
      instance_eval(&Proc.new)
    end

    # protected

    def tmp_dir
      FileUtils.mkdir_p @tmp_dir
      @tmp_dir
    end

    private

    def load_defaults!
      # Add default collectors
      DEFAULT_COLLECTORS.each do |collector_class|
        @collectors.add_collector(collector_class)
      end

      @tmp_dir = Dir.tmpdir
    end
  end
end
