source "https://rubygems.org"

# Specify your gem's dependencies in rack-webprofiler.gemspec
gemspec

group :development do
  gem "guard"
  gem "guard-sass", require: false
  gem "guard-uglify", require: false
  gem "guard-rack", require: false
  gem 'guard-rspec', require: false

  gem "shotgun"
  gem "pry"
end

group :test do
  gem "simplecov", require: false
  gem "rubocop", "~> 0.38.0", require: false
  gem "flog"
  gem "flay"
  gem "ruby2ruby"
  gem "yard"
  gem "bundler-audit"
end
