# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opencpu/version'

Gem::Specification.new do |spec|
  spec.name          = "opencpu"
  spec.version       = OpenCPU::VERSION
  spec.authors       = ["Ivan Malykh"]
  spec.email         = ["ivan@roqua.nl"]
  spec.summary       = %q{Wrapper around OpenCPU REST API}
  spec.description   = %q{This gem wraps the OpenCPU REST API.}
  spec.homepage      = "http://roqua.nl"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency             'yajl-ruby',    '~> 1.2.0'
  spec.add_dependency             'httparty',     '~> 0.12.0'
  spec.add_development_dependency 'bundler',      '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec',        '~> 2.14.1'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'vcr',          '~> 2.9.0'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-bundler'
end
