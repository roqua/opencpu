module OpenCPU
  class UnsupportedFormatError < StandardError; end
  class ResponseNotAvailableError < StandardError; end
  
  class DelayedCalculation
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

    private

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
  end
end
