require 'spec_helper'

describe Roqua::OpenCPU::Client do

  it 'initializes with HTTParty' do
    expect(described_class.ancestors).to include HTTParty
  end

  context 'configured' do
    before do
      Roqua::OpenCPU.configure do |config|
        config.endpoint_url = 'https://staging.opencpu.roqua.nl/ocpu'
      end
    end

    it 'initializes with configured attributes' do
      expect(described_class.new.class.base_uri).to eq 'https://staging.opencpu.roqua.nl/ocpu'
    end
  end

  it 'defines #execute' do
    expect(described_class.new).to respond_to :execute
  end

  describe '#execute' do
    before do
      Roqua::OpenCPU.configure do |config|
        config.endpoint_url = 'https://staging.opencpu.roqua.nl/ocpu'
      end
    end

    let(:client) { described_class.new }

    it 'returns a correct EuStockMarkets response' do
      VCR.use_cassette :eu_stock_markets do
        response = client.execute('datasets', 'EuStockMarkets', nil, :get)
        expect(response[0][0]).to eq 1628.75
        expect(response[0][1]).to eq 1678.1
      end
    end
  end
end
