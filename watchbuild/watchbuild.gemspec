# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'watchbuild/version'

Gem::Specification.new do |spec|
  spec.name          = "watchbuild"
  spec.version       = WatchBuild::VERSION
  spec.authors       = ["Felix Krause"]
  spec.email         = ["watchbuild@krausefx.com"]
  spec.summary       = WatchBuild::DESCRIPTION
  spec.description   = WatchBuild::DESCRIPTION
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w( bin/watchbuild README.md LICENSE )

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'fastlane_core', '>= 0.43.1', '< 1.0.0' # all shared code and dependencies
  spec.add_dependency 'spaceship', '>= 0.26.2', '< 1.0.0' # communication with Apple
  spec.add_dependency 'terminal-notifier' # show a notification once the build is ready

  # Development only
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'fastlane'
  spec.add_development_dependency "rubocop", '~> 0.38.0'
end
