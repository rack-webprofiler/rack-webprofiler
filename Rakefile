require "bundler/gem_tasks"
require "rubocop/rake_task"
require "rspec/core/rake_task"
require "yard"
require File.dirname(__FILE__) + '/lib/rack/webprofiler'

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  t.files         = ["lib/**/*.rb"]
  t.stats_options = ["--list-undoc"]
  t.options += ['--title', "Rack::WebProfiler #{Rack::WebProfiler::VERSION} Documentation"]
end

RuboCop::RakeTask.new do
  # task.requires << "rubocop-rspec"
end

task default: :spec
