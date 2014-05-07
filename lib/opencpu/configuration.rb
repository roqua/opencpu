module OpenCPU
  class Configuration
    attr_accessor :endpoint_url
    attr_accessor :username
    attr_accessor :password
    attr_accessor :mode
    attr_accessor :fake_response

    def fake_response
      @fake_response || {foo: 'bar'}
    end
  end
end
