# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/web_profiler/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-webprofiler"
  spec.version       = Rack::WebProfiler::VERSION
  spec.authors       = ["Nicolas Brousse"]
  spec.email         = ["pro@nicolas-brousse.fr"]

  spec.summary       = %q{A Rack profiler for web application.}
  # spec.description   = %q{}
  spec.homepage      = "http://github.com/nicolas-brousse/rack-webprofiler"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", ">= 1.6.4"
  spec.add_dependency "docile", "~> 1.1"
  spec.add_dependency "sequel", "~> 4"
  spec.add_dependency "sqlite3", "~> 1.3"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
