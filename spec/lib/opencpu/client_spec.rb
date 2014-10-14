require 'spec_helper'

describe OpenCPU::Client do

  before do
    OpenCPU.configure do |config|
      config.endpoint_url = 'https://public.opencpu.org/ocpu'
    end
  end

  it 'initializes with HTTMultiParty' do
    expect(described_class.ancestors).to include HTTMultiParty
  end

  it 'defines #execute' do
    expect(described_class.new).to respond_to :execute
  end

  it 'defines #prepare' do
    expect(described_class.new).to respond_to :prepare
  end

  describe 'initializes' do

    describe 'without configured attributes' do
      it 'uses the default timeout' do
        expect(described_class.new.class.default_options[:timeout]).to be_nil
      end
    end

    describe 'with configured attributes' do
      before do
        OpenCPU.configure do |config|
          config.endpoint_url = 'https://public.opencpu.org/ocpu'
          config.timeout      = 123
        end
      end

      it 'sets base uri' do
        expect(described_class.new.class.base_uri).to eq 'https://public.opencpu.org/ocpu'
      end

      it 'sets default_timeout' do
        expect(described_class.new.class.default_options[:timeout]).to eq 123
      end
    end
  end

  describe '#prepare' do
    let(:client) { described_class.new }
    let(:delayed_calculation) { client.prepare('digest', 'hmac', data: { key: "baz", object: "qux" }) }

    it 'returns a DelayedCalculation' do
      VCR.use_cassette :prepare do
        expect(delayed_calculation).to be_a OpenCPU::DelayedCalculation
      end
    end

    it 'returns a DelayedCalculation with correct path' do
      VCR.use_cassette :prepare do
        expect(delayed_calculation.location).to match "https://public.opencpu.org/ocpu/tmp/x[0-9a-f]+/"
      end
    end
  end

  describe '#execute' do
    after do
      OpenCPU.disable_test_mode!
    end
    let(:client) { described_class.new }

    it 'is used to quickly return JSON results' do
      VCR.use_cassette :animation_flip_coin, record: :new_episodes do
        response = client.execute(:animation, 'flip.coin')
        expect(response).to include('freq', 'nmax')
      end
    end

    it 'accepts R-function parameters as data' do
      VCR.use_cassette :digest_hmac do
        response = client.execute(:digest, :hmac, data: { key: 'baz', object: 'qux' })
        expect(response).to eq ["22e2a7a268bf076801eefe7cd0119bb9"]
      end
    end

    it 'raises 400 with body' do
      VCR.use_cassette :digest_hmac_no_parameters do
        expect { client.execute(:digest, :hmac) }.to raise_error
      end
    end

    context 'user packages' do
      before do
        OpenCPU.configure do |config|
          config.endpoint_url = 'https://staging.opencpu.roqua.nl/ocpu'
          config.username     = 'foo'
          config.password     = 'bar'
          config.timeout      = 123
        end
      end
      after { OpenCPU.reset_configuration! }
      let(:client) { described_class.new }

      it "can access user packages" do
        VCR.use_cassette :user_digest_hmac do
          response = client.execute(:digest, :hmac, user: 'deploy', data: { key: 'foo', object: 'bar' })
          expect(response).to eq ["0c7a250281315ab863549f66cd8a3a53"]
        end
      end
    end

    context 'when in test mode' do
      it 'has an empty fake response when just enabled' do
        OpenCPU.enable_test_mode!
        response = client.execute(:digest, :hmac, data: { key: 'baz', object: 'qux' })
        expect(response).to be_nil
      end

      context 'setting fake responses' do
        before do
          OpenCPU.enable_test_mode!
          OpenCPU.set_fake_response! :digest,    :hmac,       'response'
          OpenCPU.set_fake_response! :animation, 'flip.coin', {response: 2}
          OpenCPU.set_fake_response! :animation, 'flip.test', {response: 3}
        end

        it 'returns a fake response per R-script' do
          expect(client.execute(:digest, :hmac)).to eq 'response'
          expect(client.execute(:animation, 'flip.coin')).to eq({response: 2})
          expect(client.execute(:animation, 'flip.test')).to eq({response: 3})
        end
      end
    end
  end

  describe '#request_options' do
    it 'uses verify_ssl setting' do
      expect(described_class.new.send(:request_options, {}, nil)[:verify]).to be_truthy
      OpenCPU.configure do |config|
        config.verify_ssl = false
      end
      expect(described_class.new.send(:request_options, {}, nil)[:verify]).to be_falsy
    end
  end
end
