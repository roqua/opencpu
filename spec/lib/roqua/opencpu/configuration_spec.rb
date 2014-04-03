require 'spec_helper'

describe Roqua::OpenCPU::Configuration do

  it 'has an #endpoint_url' do
    expect(described_class.new).to respond_to :endpoint_url
  end

  describe '#endpoint_url=' do
    it 'sets an url' do
      config = described_class.new
      config.endpoint_url = 'http://test.com'
      expect(config.endpoint_url).to eq 'http://test.com'
    end
  end
end
