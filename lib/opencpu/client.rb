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

    def execute(package, function, data = {})
      options = default_options.merge body: data.to_json, headers: { "Content-Type" => 'application/json' }
      response = self.class.send(:post, "/library/#{package}/R/#{function}/json", options)
      if response.ok?
        return JSON.parse(response.body)
      else
        raise 'Error parsing JSON from OpenCPU'
      end
    end

    def prepare(package, function, data = {})
      options = default_options.merge body: data.to_json, headers: { "Content-Type" => 'application/json' }
      response = self.class.post("/library/#{package}/R/#{function}", options)
      @location ||= response.headers['location']
    end

    def graphics(type = :svg)
      self.class.get "#{@location}graphics/1/#{type.to_s}"
    end

    def value
      self.class.get "#{@location}R/.val"
    end

    def stdout
      self.class.get "#{@location}stdout"
    end

    def warnings
      self.class.get "#{@location}warnings"
    end

    def source
      self.class.get "#{@location}source"
    end

    def console
      self.class.get "#{@location}console"
    end

    def info
      self.class.get "#{@location}info"
    end

    def reset
      @location = nil
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
