module Rack
  # AutoConfigure::Rails
  class WebProfiler::AutoConfigure::Rails
    class Engine < ::Rails::Engine # :nodoc:
      initializer "active_profiler.configure_middleware" do |app|
        app.middleware.use Rack::WebProfiler do |c|
          c.tmp_dir = File.expand_path(File.join(Rails.root, "tmp"), __FILE__)
        end
      end
    end
  end
end
