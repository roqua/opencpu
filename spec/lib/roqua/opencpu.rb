require File.expand_path('../../spec_helper.rb', __dir__)

describe Roqua::OpenCPU do

  it 'responds to #client' do
    expect(described_class).to respond_to :client
  end

  it 'responds to #configure' do
    expect(described_class).to respond_to :configure
  end

  it 'responds to #configuration' do
    expect(Roqua::OpenCPU).to respond_to :configuration
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

  describe '#client' do

  end
end
