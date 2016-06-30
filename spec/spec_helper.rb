require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'vcr'
require 'byebug'

require File.expand_path('../../lib/opencpu.rb', __FILE__)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_hosts 'codeclimate.com'
end
