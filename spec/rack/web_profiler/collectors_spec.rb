require "spec_helper"

describe Rack::WebProfiler::Collectors do
  it "register and unregister collectors corectly" do
    collector_list = {
      time: Rack::WebProfiler::Collector::TimeCollector,
      rack: Rack::WebProfiler::Collector::Rack::RackCollector,
      ruby: Rack::WebProfiler::Collector::RubyCollector,
    }
    collectors = Rack::WebProfiler::Collectors.new

    # add
    collectors.add_collector Rack::WebProfiler::Collector::TimeCollector
    collectors.add_collector [
      Rack::WebProfiler::Collector::Rack::RackCollector,
      Rack::WebProfiler::Collector::RubyCollector,
    ]

    collector_list.each do |name, klass|
      definition = collectors.all[name.to_sym]
      expect(definition).to be_a(Rack::WebProfiler::Collector::Definition)
      expect(definition.klass).to be(klass)
    end

    # remove
    collectors.remove_collector Rack::WebProfiler::Collector::TimeCollector
    collectors.remove_collector [
      Rack::WebProfiler::Collector::Rack::RackCollector,
      Rack::WebProfiler::Collector::RubyCollector,
    ]

    collector_list.each do |name, _klass|
      definition = collectors.all[name.to_sym]
      expect(definition).to be_nil
    end
  end

  it "does not allow to register twice the same collector" do
    collectors = Rack::WebProfiler::Collectors.new
    collectors.add_collector Rack::WebProfiler::Collector::TimeCollector

    expect { collectors.add_collector "Rack::WebProfiler::Collector::TimeCollector" }.to raise_error(ArgumentError)
    expect { collectors.add_collector Rack::WebProfiler::Collector::TimeCollector }.to raise_error(ArgumentError)
  end

  it "does not allow to unregister collector that was not previously registrered" do
    class UnregisteredCollector; end

    expect { Rack::WebProfiler.unregister_collector "UnregisteredCollector" }.to raise_error(ArgumentError)
    expect { Rack::WebProfiler.unregister_collector UnregisteredCollector }.to raise_error(ArgumentError)
  end

  it "does not allow to register a collector with a name already used" do
    class CustomCollector
      include Rack::WebProfiler::Collector::DSL

      icon nil

      collector_name "rack_request"
      position       3

      collect do |request, _response|
        store :request_fullpath,  request.fullpath
      end

      template __FILE__, type: :DATA
    end

    collectors = Rack::WebProfiler::Collectors.new
    collectors.add_collector Rack::WebProfiler::Collector::RequestCollector

    expect { collectors.add_collector CustomCollector }.to raise_error(ArgumentError)
  end

  it "does not allow to register a collector who not use the DSL" do
    class OtherCustomCollector; end

    collectors = Rack::WebProfiler::Collectors.new

    expect { collectors.add_collector OtherCustomCollector }.to raise_error(ArgumentError)
  end

  it "returns the asked collector by name" do
    collectors = Rack::WebProfiler::Collectors.new
    collectors.add_collector Rack::WebProfiler::Collector::TimeCollector
    definition = collectors.definition_by_name :time

    expect(definition).to be_a(Rack::WebProfiler::Collector::Definition)
    expect(definition.klass).to be(Rack::WebProfiler::Collector::TimeCollector)
  end

  it "works to register a collector from Rack::WebProfiler" do
    class CustomCollector
      include Rack::WebProfiler::Collector::DSL

      icon nil

      collector_name "custom"
      position       3

      collect do |request, _response|
        store :request_fullpath,  request.fullpath
      end

      template __FILE__, type: :DATA
    end

    Rack::WebProfiler.register_collector CustomCollector

    definition = Rack::WebProfiler.config.collectors.all[:time]
    expect(definition).to be_a(Rack::WebProfiler::Collector::Definition)
    expect(definition.klass).to be(Rack::WebProfiler::Collector::TimeCollector)
  end

  it "works to unregister a collector from Rack::WebProfiler" do
    Object.send(:remove_const, :CustomCollector)

    class CustomCollector
      include Rack::WebProfiler::Collector::DSL

      icon nil

      collector_name "other_custom"
      position       3

      collect do |request, _response|
        store :request_fullpath,  request.fullpath
      end

      template __FILE__, type: :DATA
    end

    Rack::WebProfiler.register_collector CustomCollector
    Rack::WebProfiler.unregister_collector CustomCollector

    definition = Rack::WebProfiler.config.collectors.all[:other_custom]
    expect(definition).to be(nil)
  end
end
