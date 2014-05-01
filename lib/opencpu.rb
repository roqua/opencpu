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
end


require "opencpu/configuration"
require "opencpu/client"
require "opencpu/delayed_calculation"
require "opencpu/version"
