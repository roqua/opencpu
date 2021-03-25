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

  spec.files         = Dir["{lib,vendor}/**/*"] + ["README.md", "LICENSE.txt"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths =  Dir["spec/**/*"]

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency             'yajl-ruby',      '~> 1.3',     '>= 1.3.1'
  spec.add_dependency             'httparty',  '~> 0.16'

  spec.add_development_dependency 'bundler',        '>= 1.6.0'
  spec.add_development_dependency 'rake',           '>= 12.3.3'
  spec.add_development_dependency 'rspec',          '~> 2.14',    '>= 2.14.1'
  spec.add_development_dependency 'webmock',        '~> 3.12'
  spec.add_development_dependency 'vcr',            '~> 6.0'
end
