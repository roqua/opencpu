require 'spec_helper'

describe OpenCPU::Configuration do

  it 'has an #endpoint_url' do
    expect(described_class.new).to respond_to :endpoint_url
  end

  it 'has a #username' do
    expect(described_class.new).to respond_to :username
  end

  it 'has a #password' do
    expect(described_class.new).to respond_to :password
  end

  describe '#endpoint_url=' do
    it 'sets an url' do
      config = described_class.new
      config.endpoint_url = 'http://test.com'
      expect(config.endpoint_url).to eq 'http://test.com'
    end
  end

  describe '#username=' do
    it 'sets a username' do
      config = described_class.new
      config.username = 'foo'
      expect(config.username).to eq 'foo'
    end
  end

  describe '#password=' do
    it 'sets the password' do
      config = described_class.new
      config.password = 'bar'
      expect(config.password).to eq 'bar'
    end
  end
end
