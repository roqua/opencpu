module OpenCPU
  class Client
    include HTTParty

    def initialize
      self.class.base_uri OpenCPU.configuration.endpoint_url
    end

    def execute(package, function, data = {})
      process_query package_url(package, function, :json), data do |response|
        JSON.parse(response.body)
      end
    end

    def prepare(package, function, data = {})
      process_query package_url(package, function), data do |response|
        location  = response.headers['location']
        resources = response.body.split(/\n/)
        OpenCPU::DelayedCalculation.new(location, resources)
      end
    end

    private

    def process_query(url, data, &block)
      options   = { body: data.to_json, headers: { "Content-Type" => 'application/json' } }
      response  = self.class.post(url, options)
      
      case response.code
      when 200..201
        return yield(response)
      when 400
        raise '400: Bad Request\n' + response.body
      else
        raise 'Error'
      end
    end

    def package_url(package, function, format = nil)
      "/library/#{package.to_s}/R/#{function.to_s}/#{format.to_s}"
    end
  end
end
