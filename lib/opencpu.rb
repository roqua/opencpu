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
    self.configuration.mode = 'test'
  end

  def self.disable_test_mode!
    self.configuration.mode = nil
  end

  def self.test_mode?
    self.configuration.mode == 'test'
  end

  def self.set_fake_response!(response)
    self.configuration.fake_response = response
  end
end


require "opencpu/configuration"
require "opencpu/client"
require "opencpu/delayed_calculation"
require "opencpu/version"
