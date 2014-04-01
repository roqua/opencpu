require 'httparty'
require 'yajl'
require "roqua/opencpu/version"

begin
  require "pry"
rescue LoadError
end

module Roqua
  module OpenCPU
    class UnsupportedHTTPMethod < StandardError; end

    include HTTParty

    format   :json
    headers  'Content-Type' => 'application/json'
    base_uri 'http://10.210.50.11/ocpu'

    def self.execute(package, function, data, method = :post)
      raise UnsupportedHTTPMethod if method != :post
      self.send(method, "/library/#{package}/R/#{function}/json", body: data)
    end
  end
end
