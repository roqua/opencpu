require 'httparty'
require 'yajl'

begin
  require "pry"
rescue LoadError
end


module OpenCPU
  class << self
    attr_writer :configuration
  end

  def self.client
    OpenCPU::Client.new
  end

  def self.configuration
    @configuration ||= OpenCPU::Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.enable_test_mode!
    self.configuration.fake_responses = {}
    self.configuration.mode = 'test'
  end

  def self.disable_test_mode!
    self.configuration.mode = nil
    self.configuration.fake_responses = {}
  end

  def self.test_mode?
    self.configuration.mode == 'test'
  end

  def self.set_fake_response!(package, script, response = nil)
    key = [package, script].join('/')
    self.configuration.add_fake_response key, response
  end

  def self.reset_configuration!
    self.configuration.reset!
  end
end


require "opencpu/configuration"
require "opencpu/client"
require "opencpu/delayed_calculation"
require "opencpu/version"
