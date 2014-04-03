require 'httparty'
require 'yajl'

begin
  require "pry"
rescue LoadError
end

module Roqua
  module OpenCPU

    class << self
      attr_writer :configuration
    end

    def self.client
      Client.new
    end

    def self.configuration
      @configuration ||= Roqua::OpenCPU::Configuration.new
    end

    def self.configure
      yield(configuration)
    end
  end
end

require "roqua/opencpu/configuration"
require "roqua/opencpu/client"
require "roqua/opencpu/version"
