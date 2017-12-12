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

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency             'yajl-ruby',      '~> 1.3',     '>= 1.3.1'
  spec.add_dependency             'httmultiparty',  '~> 0.3.16'

  spec.add_development_dependency 'bundler',        '~> 1.6',     '>= 1.6.0'
  spec.add_development_dependency 'rake',           '~> 10.3',    '>= 10.3.1'
  spec.add_development_dependency 'rspec',          '~> 2.14',    '>= 2.14.1'
  spec.add_development_dependency 'webmock',        '~> 1.17',    '>= 1.17.4'
  spec.add_development_dependency 'vcr',            '~> 2.9',     '>= 2.9.0'
end
