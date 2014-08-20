module OpenCPU
  class Configuration
    attr_accessor :endpoint_url
    attr_accessor :timeout
    attr_accessor :username
    attr_accessor :password
    attr_accessor :mode
    attr_accessor :fake_responses

    def initialize
      @fake_responses = {}
    end

    def add_fake_response(key, response)
      @fake_responses[key] = response
    end

    def remove_fake_response(key)
      @fake_responses.delete key
    end

    def reset!
      @endpoint_url   = nil
      @timeout        = nil
      @username       = nil
      @password       = nil
      @mode           = nil
      @fake_responses = {}
    end
  end
end
