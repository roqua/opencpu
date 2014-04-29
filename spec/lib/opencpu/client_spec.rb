require 'spec_helper'

describe OpenCPU::Client do

  it 'initializes with HTTParty' do
    expect(described_class.ancestors).to include HTTParty
  end

  it 'provides #default_options' do
    expect(described_class.new).to respond_to :default_options
  end

  context 'configured' do
    before do
      OpenCPU.configure do |config|
        config.endpoint_url = 'https://public.opencpu.org/ocpu'
        config.username     = 'foo'
        config.password     = 'bar'
      end
    end

    it 'initializes with configured attributes' do
      expect(described_class.new.class.base_uri).to eq 'https://public.opencpu.org/ocpu'
      expect(described_class.new.default_options).to eq({basic_auth: {username: 'foo', password: 'bar'}})
    end
  end

  it 'defines #execute' do
    expect(described_class.new).to respond_to :execute
  end

  describe '#execute' do
    before do
      OpenCPU.configure do |config|
        config.endpoint_url = 'https://public.opencpu.org/ocpu'
        config.username     = 'foo'
        config.password     = 'bar'
      end
    end

    let(:client) { described_class.new }

    it 'returns a correct HMAC response' do
      VCR.use_cassette :digest_hmac do
        response = client.execute('digest', 'hmac', { key: 'baz', object: 'qux' })
        expect(response[0]).to eq '22e2a7a268bf076801eefe7cd0119bb9'
      end
    end
  end

  it 'defines #prepare and resource getters' do
    expect(described_class.new).to respond_to :prepare
    expect(described_class.new).to respond_to :value
    expect(described_class.new).to respond_to :stdout
    expect(described_class.new).to respond_to :warnings
    expect(described_class.new).to respond_to :info
    expect(described_class.new).to respond_to :console
  end

  describe 'preparing and getting resources' do
    before do
      OpenCPU.configure do |config|
        config.endpoint_url = 'https://public.opencpu.org/ocpu'
        config.username     = 'foo'
        config.password     = 'bar'
      end
    end
    let(:client) { described_class.new }

    it 'sends initial request to OpenCPU and gets cache location' do
      VCR.use_cassette :prepare do
        client.prepare('digest', 'hmac', { key: "baz", object: "qux" })
        expect(client.location).to eq "https://public.opencpu.org/ocpu/tmp/x0997a7e8eb/"
      end
    end

    it 'returns cached R value' do
      VCR.use_cassette :get_value do
        client.reset
        client.prepare('digest', 'hmac', { key: "baz", object: "qux" })
        response = client.value
        expect(response.body).to include("22e2a7a268bf076801eefe7cd0119bb9")
      end
    end

    it 'returns cached stdout' do
      VCR.use_cassette :get_stdout do
        client.reset
        client.prepare('digest', 'hmac', { key: "baz", object: "qux" })
        response = client.stdout
        expect(response.body).to include("22e2a7a268bf076801eefe7cd0119bb9")
      end
    end

    it 'returns cached warnings' do
      VCR.use_cassette :get_warnings do
        client.reset
        client.prepare('digest', 'hmac', { key: "baz", object: "qux" })
        response = client.warnings
        expect(response.body).to include("the condition has length > 1")
      end
    end

    it 'returns cached info' do
      VCR.use_cassette :get_info do
        client.reset
        client.prepare('digest', 'hmac', { key: "baz", object: "qux" })
        response = client.info
        expect(response.body).to include("R version")
      end
    end

    it 'returns cached console input' do
      VCR.use_cassette :get_console do
        client.reset
        client.prepare('digest', 'hmac', { key: "baz", object: "qux" })
        response = client.console
        expect(response.body).to include("hmac(key = \"baz\", object = \"qux\"")
      end
    end

    it 'returns cached graphics' do
      VCR.use_cassette :get_graphics do
        client.reset
        client.prepare('graphics', 'plot', { x: [5, 6, 7, 8, 9, 10], y: [10, 8, 11, 1, 4, 3] })

        response = client.graphics
        expect(response.body).to include("svg xmlns")
      end
    end
  end

end
