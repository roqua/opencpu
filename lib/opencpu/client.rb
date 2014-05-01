module OpenCPU
  class Client
    class UnsupportedHTTPMethod < StandardError; end
    include HTTParty

    attr_accessor :location

    def initialize
      self.class.base_uri OpenCPU.configuration.endpoint_url
    end

    def default_options
      {
        basic_auth: {
          username: OpenCPU.configuration.username,
          password: OpenCPU.configuration.password
        }
      }
    end
  end
end
