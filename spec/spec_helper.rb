require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'vcr'

require File.expand_path('../../lib/opencpu.rb', __FILE__)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_hosts 'codeclimate.com'
  c.allow_http_connections_when_no_cassette = true
end
