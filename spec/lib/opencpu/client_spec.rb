require 'spec_helper'

describe OpenCPU::Client do

  before do
    OpenCPU.configure do |config|
      config.endpoint_url = 'https://public.opencpu.org/ocpu'
    end
  end

  it 'initializes with HTTParty' do
    expect(described_class.ancestors).to include HTTParty
  end

  it 'defines #execute' do
    expect(described_class.new).to respond_to :execute
  end

  it 'defines #prepare' do
    expect(described_class.new).to respond_to :prepare
  end

  describe 'initializes' do
    before do
      OpenCPU.configure do |config|
        config.endpoint_url = 'https://public.opencpu.org/ocpu'
      end
    end

    it 'with configured attributes' do
      expect(described_class.new.class.base_uri).to eq 'https://public.opencpu.org/ocpu'
    end
  end

  describe '#prepare' do
    let(:client) { described_class.new }
    let(:delayed_calculation) { client.prepare('digest', 'hmac', key: "baz", object: "qux") }

    it 'returns a DelayedCalculation' do
      VCR.use_cassette :prepare do
        expect(delayed_calculation).to be_a OpenCPU::DelayedCalculation
      end
    end

    it 'returns a DelayedCalculation with correct path' do
      VCR.use_cassette :prepare do
        expect(delayed_calculation.location).to eq "https://public.opencpu.org/ocpu/tmp/x0a79915480/"
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
        expect(response).to eq "freq" => [0.56, 0.44], "nmax" => [50]
      end
    end

    it 'accepts R-function parameters as data' do
      VCR.use_cassette :digest_hmac, record: :new_episodes do
        response = client.execute(:digest, :hmac, key: 'baz', object: 'qux')
        expect(response).to eq ["22e2a7a268bf076801eefe7cd0119bb9"]
      end
    end

    it 'raises 400 with body' do
      VCR.use_cassette :digest_hmac_no_parameters do
        expect { client.execute(:digest, :hmac) }.to raise_error
      end
    end

    context 'when in test mode' do
      it 'returns a default fake response' do
        OpenCPU.enable_test_mode!
        response = client.execute(:digest, :hmac, key: 'baz', object: 'qux')
        expect(response).to eq({ foo: "bar" })
      end
    end
  end

end
