require 'opencpu/errors'

module OpenCPU
  class Client
    include Errors
    include HTTMultiParty

    def initialize
      self.class.base_uri OpenCPU.configuration.endpoint_url
      self.class.default_timeout(OpenCPU.configuration.timeout) unless OpenCPU.configuration.timeout.nil?
    end

    def execute(package, function, options = {})
      user                      = options.fetch :user, :system
      data                      = options.fetch :data, {}
      format                    = options.fetch :format, :json
      github_remote             = options.fetch :github_remote, false
      should_convert_na_to_nil  = options.fetch :convert_na_to_nil, false

      process_query function_url(package, function, user, github_remote, :json), data, format do |response|
        output = JSON.parse(response.body)
        output = convert_na_to_nil(output) if should_convert_na_to_nil
        output
      end
    end

    def description(package, options = {})
      user          = options.fetch :user, :system
      github_remote = options.fetch :github_remote, false

      url = "#{package_url(package, user, github_remote)}/info"
      self.class.get(url, request_options(nil, :json))
    end

    def convert_na_to_nil(data)
      case data
      when 'NA'
        nil
      when Hash
        data.each { |k, v| data[k] = convert_na_to_nil(v) }
      when Array
        data.map! { |v| convert_na_to_nil(v) }
      else
        data
      end
    end

    def prepare(package, function, options = {})
      user = options.fetch :user, :system
      data = options.fetch :data, {}
      format = options.fetch :format, :json
      github_remote = options.fetch :github_remote, false
      process_query function_url(package, function, user, github_remote), data, format do |response|
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

    def function_url(package, function, user = :system, github_remote = false, format = nil)
      "#{package_url(package, user, github_remote)}/#{function}/#{format.to_s}"
      # "#{package_url(package, user, github_remote)}/R/#{function}/#{format.to_s}"
    end

    def package_url(package, user = :system, github_remote = false)
      return "/library/#{package}" if user == :system
      return "/github/#{user}/#{package}" if github_remote
      return "/user/#{user}/library/#{package}"
    end

    def fake_response_for(url)
      key = derive_key_from_url(url)
      OpenCPU.configuration.fake_responses.delete key
    end

    def derive_key_from_url(url)
      url_parts    = url.gsub!(/^\//, '').split('/')
      remove_items = ['R', 'library', 'json']
      (url_parts - remove_items).join('/')
    end
  end
end
