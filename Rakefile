require "bundler/gem_tasks"
require "rubocop/rake_task"
require "rspec/core/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  t.files   = ["lib/**/*.rb"]
  t.stats_options = ["--list-undoc"]
end

RuboCop::RakeTask.new do
  # task.requires << "rubocop-rspec"
end

task default: :spec
