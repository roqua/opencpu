module Roqua
  module OpenCPU
    class Client
      class UnsupportedHTTPMethod < StandardError; end
      include HTTParty
      format   :json
      headers  'Content-Type' => 'application/json'

      def initialize
        self.class.base_uri Roqua::OpenCPU.configuration.endpoint_url
      end

      def execute(package, function, data = nil, method = :post)
        raise UnsupportedHTTPMethod if unsupported_http_method? method
        self.class.send(method, "/library/#{package}/R/#{function}/json", body: data.to_json)
      end

      private

      def supported_http_methods
        [:post]
      end

      def unsupported_http_method?(method)
        !supported_http_methods.include? method
      end
    end
  end
end
