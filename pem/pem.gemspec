# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pem/version'

Gem::Specification.new do |spec|
  spec.name          = "pem"
  spec.version       = PEM::VERSION
  spec.authors       = ["Felix Krause"]
  spec.email         = ["pem@krausefx.com"]
  spec.summary       = 'Automatically generate and renew your push notification profiles'
  spec.description   = 'Automatically generate and renew your push notification profiles'
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w( bin/pem README.md LICENSE )

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'fastlane_core', '>= 0.43.1', '< 1.0.0' # all shared code and dependencies
  spec.add_dependency 'spaceship', '>= 0.26.2', '< 1.0.0' # Communicating with the Apple Dev Portal

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
