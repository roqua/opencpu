require 'vcr'

require File.expand_path('../../lib/opencpu.rb', __FILE__)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end
