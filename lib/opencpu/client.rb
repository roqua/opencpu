module OpenCPU
  class Client
    include HTTParty

    def initialize
      self.class.base_uri OpenCPU.configuration.endpoint_url
    end

    # def execute(package, function, data = {})
    #   options = default_options.merge body: data.to_json, headers: { "Content-Type" => 'application/json' }
    #   response = self.class.send(:post, "/library/#{package}/R/#{function}/json", options)
    #   if response.ok?
    #     return JSON.parse(response.body)
    #   else
    #     raise 'Error parsing JSON from OpenCPU'
    #   end
    # end

    def prepare(package, function, data = {})
      options   = default_options.merge body: data.to_json, headers: { "Content-Type" => 'application/json' }
      response  = self.class.post("/library/#{package}/R/#{function}", options)
      location  = response.headers['location']
      resources = response.body.split(/\n/)
      OpenCPU::DelayedCalculation.new(location, resources)
    end

    private

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
