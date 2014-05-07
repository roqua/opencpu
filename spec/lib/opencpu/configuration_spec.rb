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

  it 'has a #mode' do
    expect(described_class.new).to respond_to :mode
  end

  it 'defines #fake_responses Hash' do
    config = described_class.new
    expect(config).to respond_to :fake_responses
    expect(config.fake_responses).to be_a Hash
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

  describe '#mode=' do
    it 'sets the mode to test' do
      config = described_class.new
      config.mode = 'test'
      expect(config.mode).to eq 'test'
    end
  end

  describe '#fake_responses' do
    let(:config) { described_class.new }
    it 'sets an empty fake responses' do
      expect(config.fake_responses).to eq({})
    end

    it 'sets fake responses for R packages' do
      config.add_fake_response 'foo/bar', {baz: 'qux'}
      expect(config.fake_responses).to eq({'foo/bar' => {baz: 'qux'}})
    end

    it 'removes a fake response by key' do
      config.remove_fake_response 'foo/bar'
      expect(config.fake_responses).to eq({})
    end
  end
end
