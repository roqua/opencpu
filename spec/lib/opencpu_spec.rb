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

  it "responds to #enable_test_mode" do
    expect(described_class).to respond_to :enable_test_mode!
  end

  it "responds to #disable_test_mode" do
    expect(described_class).to respond_to :disable_test_mode!
  end

  describe '#configure' do
    before do
      described_class.configure do |config|
        config.endpoint_url = 'http://somehost.com/opencpu'
      end
    end

    it "can configure" do
      expect(described_class.configuration.endpoint_url).to eq 'http://somehost.com/opencpu'
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
      expect(described_class.test_mode?).to be_true
      described_class.disable_test_mode!
      expect(described_class.test_mode?).to be_false
    end

    it 'sets default fake response when in test mode' do
      described_class.enable_test_mode!
      expect(OpenCPU.configuration.fake_response).to eq({foo: 'bar'})
    end

    it 'can set optional fake response' do
      described_class.enable_test_mode!
      described_class.set_fake_response!({baz: 'qux'})
      expect(OpenCPU.configuration.fake_response).to eq({baz: 'qux'})
    end
  end
end
