require "spec_helper"

describe Rack::WebProfiler::Config do
  it "build configuration from block on Config" do
    class CustomCollector
      include Rack::WebProfiler::Collector::DSL

      identifier "custom"
    end

    config = Rack::WebProfiler::Config.new
    config.build! do |c|
      c.tmp_dir = "./tmp"
    end

    config.collectors.add_collector CustomCollector

    expect(config.collectors.all.keys).to include(:custom)
    expect(config.tmp_dir).to eq("./tmp")
    expect(config).to be_a(Rack::WebProfiler::Config)
  end
end
