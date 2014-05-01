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
        expect(delayed_calculation.location).to eq "https://public.opencpu.org/ocpu/tmp/x0997a7e8eb/"
      end
    end
  end

  # describe '#execute' do
  #   before do
  #     OpenCPU.configure do |config|
  #       config.endpoint_url = 'https://public.opencpu.org/ocpu'
  #     end
  #   end

  #   let(:client) { described_class.new }

  #   it 'returns a correct HMAC response' do
  #     VCR.use_cassette :digest_hmac do
  #       response = client.execute('digest', 'hmac', { key: 'baz', object: 'qux' })
  #       expect(response[0]).to eq '22e2a7a268bf076801eefe7cd0119bb9'
  #     end
  #   end
  # end

end
