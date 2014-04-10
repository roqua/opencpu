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
        config.endpoint_url = 'https://staging.opencpu.roqua.nl/ocpu'
        config.username     = 'foo'
        config.password     = 'bar'
      end
    end

    it 'initializes with configured attributes' do
      expect(described_class.new.class.base_uri).to eq 'https://staging.opencpu.roqua.nl/ocpu'
      expect(described_class.new.default_options).to eq({basic_auth: {username: 'foo', password: 'bar'}})
    end
  end

  it 'defines #execute' do
    expect(described_class.new).to respond_to :execute
  end

  describe '#execute' do
    before do
      OpenCPU.configure do |config|
        config.endpoint_url = 'https://staging.opencpu.roqua.nl/ocpu'
        config.username     = 'foo'
        config.password     = 'bar'
      end
    end

    let(:client) { described_class.new }

    it 'returns a correct HMAC response' do
      VCR.use_cassette :digest_hmac do
        response = client.execute('digest', 'hmac', key: 'baz', object: 'qux')
        expect(response[0]).to eq '22e2a7a268bf076801eefe7cd0119bb9'
      end
    end
  end
end
