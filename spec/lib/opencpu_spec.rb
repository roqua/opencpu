require 'spec_helper'

describe OpenCPU do

  it 'responds to #client' do
    expect(described_class).to respond_to :client
  end

  it 'responds to #configure' do
    expect(described_class).to respond_to :configure
  end

  it 'responds to #configuration' do
    expect(described_class).to respond_to :configuration
  end

  it "responds to #enable_test_mode!" do
    expect(described_class).to respond_to :enable_test_mode!
  end

  it "responds to #disable_test_mode!" do
    expect(described_class).to respond_to :disable_test_mode!
  end

  it "responds to #reset_configuration!" do
    expect(described_class).to respond_to :reset_configuration!
  end

  describe '#configure' do
    before do
      described_class.configure do |config|
        config.endpoint_url = 'http://example.com/opencpu'
      end
    end

    it "can configure" do
      expect(described_class.configuration.endpoint_url).to eq 'http://example.com/opencpu'
    end
  end

  describe 'test mode' do
    after do
      described_class.disable_test_mode!
    end
    it 'enables test mode' do
      expect(described_class.configuration.mode).to be_nil
      described_class.enable_test_mode!
      expect(described_class.configuration.mode).to eq 'test'
    end

    it 'disables test mode' do
      described_class.enable_test_mode!
      expect(described_class.configuration.mode).to eq 'test'
      described_class.disable_test_mode!
      expect(described_class.configuration.mode).to be_nil
    end

    it 'checks for a test mode' do
      described_class.enable_test_mode!
      expect(described_class.test_mode?).to eq true
      described_class.disable_test_mode!
      expect(described_class.test_mode?).to eq false
    end

    it 'can set a fake response' do
      described_class.enable_test_mode!
      described_class.set_fake_response!('foo', 'bar', {baz: 'qux'})
      described_class.set_fake_response!('hoi', 'hai')
      expect(OpenCPU.configuration.fake_responses['foo/bar']).to eq({baz: 'qux'})
      expect(OpenCPU.configuration.fake_responses['hoi/hai']).to be_nil
    end
  end

  describe 'resetting configuration' do
    before do
      described_class.configure do |config|
        config.endpoint_url = 'http://example.com/opencpu'
      end
    end
    it "can reset configuration" do
      described_class.reset_configuration!
      expect(described_class.configuration.endpoint_url).to be_nil
    end
  end
end
