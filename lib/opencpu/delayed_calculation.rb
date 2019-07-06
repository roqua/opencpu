module OpenCPU
  class UnsupportedFormatError < StandardError; end
  class ResponseNotAvailableError < StandardError; end
  
  class DelayedCalculation
    include Errors
    include HTTMultiParty

    attr_accessor :location
    attr_accessor :available_resources

    def initialize(location, resources = [])
      @location = location
      @available_resources = {}
      parse_resources(location, resources)
    end

    def graphics(which = 0, type = :svg)
      raise ResponseNotAvailableError unless @available_resources.has_key?(:graphics)
      raise UnsupportedFormatError unless [:png, :svg].include?(type)
      process_resource @available_resources[:graphics][which].to_s + "/#{type}"
    end

    def value
      raise ResponseNotAvailableError unless @available_resources.has_key?(:value)
      process_resource @available_resources[:value].to_s
    end

    def stdout
      raise ResponseNotAvailableError unless @available_resources.has_key?(:stdout)
      process_resource @available_resources[:stdout].to_s
    end

    def warnings
      raise ResponseNotAvailableError unless @available_resources.has_key?(:warnings)
      process_resource @available_resources[:warnings].to_s
    end

    def source
      raise ResponseNotAvailableError unless @available_resources.has_key?(:source)
      process_resource @available_resources[:source].to_s
    end

    def console
      raise ResponseNotAvailableError unless @available_resources.has_key?(:console)
      process_resource @available_resources[:console].to_s
    end

    def info
      raise ResponseNotAvailableError unless @available_resources.has_key?(:info)
      process_resource @available_resources[:info].to_s
    end

    def keys
      @available_resources.keys
    end

    # available_resources(:"R/foo")
    def available_resources(key)
      raise ResponseNotAvailableError unless @available_resources.has_key?(key)
      process_resource @available_resources[key].to_s
    end

    def process_resources(key, options = {})
      options = {
        user: :system,
        format: :json,
        data: {}
        # method: :post
      }.merge(options)

      puts options

      raise ResponseNotAvailableError unless @available_resources.has_key?(key)
      url = @available_resources[key].to_s
      data = options[:data]
      format = options[:format]

      process_query url, data, format do |response|
        location  = response.headers['location']
        resources = response.body.split(/\n/)
        OpenCPU::DelayedCalculation.new(location, resources)
      end
    end

    private

    def process_query(url, data, format, &block)
      return fake_response_for(url) if OpenCPU.test_mode?

      response  = self.class.post(url, request_options(data, format))

      case response.code
      when 200..201
        return yield(response)
      else
        fail error_class_for(response.code), "#{response.code}:\n #{response.body}"
      end
    end

    def process_resource(resource)
      response = self.class.get resource
      if response.ok?
        response.body.strip
      end
    end

    def parse_resources(location, resources)
      resources.each do |resource|
        uri = URI.join(domain, resource)
        key = key(uri, location)
        if key == :graphics
          @available_resources[key] ||= []
          @available_resources[key] << uri
        else
          @available_resources[key] = uri
        end
      end
    end

    def domain
      uri = URI.parse(@location)
      "#{uri.scheme}://#{uri.host}:#{uri.port}"
    end

    def key(uri, location)
      key = uri.to_s.gsub(location, '')
      key = :value    if key == "R/.val"
      key = :graphics if key =~ /graphics\/\d/
      key.to_sym
    end

    def request_options(data, format)
      options = {
        verify: OpenCPU.configuration.verify_ssl
      }

      case format
      when :json
        options[:body] = data.to_json if data
        options[:headers] =  {"Content-Type" => 'application/json'}
      when :urlencoded
        options[:query] = data if data
      end

      if OpenCPU.configuration.username && OpenCPU.configuration.password
        options[:basic_auth] = {
          username: OpenCPU.configuration.username, password: OpenCPU.configuration.password
        }
      end
      options
    end

    def error_class_for(response_code)
      case response_code
      when 403
        AccessDenied
      when 400..499
        BadRequest
      when 500..599
        InternalServerError
      else
        OpenCPUError
      end
    end
  end

end
