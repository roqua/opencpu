require 'spec_helper'

describe OpenCPU::Client do
  let(:client) { described_class.new }

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

  describe '#process_query' do
    let(:client) { described_class.new}
    let(:url) { '/library/base/R/identity/json' }
    let(:data) { { some: 'data' } }
    let(:format) { :json }
    let(:response_handler) { -> { nil } }

    subject { client.send(:process_query, url, data, format) { |response| response_handler(response) } }

    context 'test mode' do
      it 'calls fake_response_for(url)' do
        allow(OpenCPU).to receive(:test_mode?).and_return true
        expect(client).to receive(:fake_response_for)
        subject
      end
    end

    context 'no test mode' do
      context 'HTTP failure' do
        it 'returns the appropiate status code' do
          VCR.use_cassette :bad_request do
            expect { subject }.to raise_error OpenCPU::Errors::BadRequest
          end
        end
      end
    end
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

    context 'url encoded request' do
      it 'sends the parameters url_encoded' do
        VCR.use_cassette :url_encoded_request do |cassette|
          client.execute(:base, :identity, format: nil, data: { x: 'data.frame(x=1,y=1)' })
          params = cassette.serializable_hash['http_interactions'][0]['request']['body']['string']
          expect(params).to eq "x=data.frame(x%3D1%2Cy%3D1)"
        end
      end
      it 'accepts R-code as parameters' do
        VCR.use_cassette :url_encoded_request do |cassette|
          response = client.execute(:base, :identity, format: nil, data: { x: 'data.frame(x=1,y=1)' })
          expect(response).to eq [{"x"=>1, "y"=>1}]
        end
      end
    end

    context 'na_to_nil = true option is given' do
      it 'converts "na" values to nil' do
        VCR.use_cassette :response_with_na_values do |cassette|
          response = client.execute(:base, :identity, format: nil, data: {}, convert_na_to_nil: true)
          expect(response).to eq [{"x"=>nil, "y"=>"not_na"}]
        end
      end
    end

    context 'multipart form / file uploads' do
      it "works" do
        skip # vcr is broken for file uploads https://github.com/vcr/vcr/issues/441
        VCR.use_cassette :multi_part_request do |cassette|
          # VCR.turn_off!
          # WebMock.disable!
          response = client.execute(:utils, 'read.csv', format: nil, data: { file: File.new('spec/fixtures/test.csv') })
          # WebMock.enable!
          # VCR.turn_on!
          expect(response).to eq [{"head1"=>1, "head2"=>2, "head3"=>3}, {"head1"=>4, "head2"=>5, "head3"=>6}]
        end
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

      it "can access user packages" do
        VCR.use_cassette :user_digest_hmac do
          response = client.execute(:digest, :hmac, user: 'deploy', data: { key: 'foo', object: 'bar' })
          expect(response).to eq ["0c7a250281315ab863549f66cd8a3a53"]
        end
      end
    end

    context 'GitHub package' do
      before do
        OpenCPU.configure do |config|
          config.endpoint_url = 'https://public.opencpu.org/ocpu'
        end
      end
      after { OpenCPU.reset_configuration! }

      it "can access github packages" do
        VCR.use_cassette :github_animation_flip_coin do
          response = client.execute(:animation, :'flip.coin', {user: "yihui", github_remote: true, data: {}})
          expect(response['nmax']).to eq [50]
          expect(response['freq'][0]).to satisfy { |result| result >= 0.0 && result <= 1.0 }
          expect(response['freq'][1]).to satisfy { |result| result >= 0.0 && result <= 1.0 }
        end
      end

      it "what happens when package is not available on GitHub" do
        VCR.use_cassette :github_animation_flip_coin_error do
          expect {
            client.execute(:foo, :bar, {user: "baz", github_remote: true})
          }.to raise_error OpenCPU::Errors::BadRequest, /400/
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

  describe '#description' do
    it 'returns the content of the package DESCRIPTION file' do
      VCR.use_cassette :description do |cassette|
        response = client.description('ade4')
        expect(response.body).to eq "Package: My package\n" \
                                    "Type: Package\n"
      end
    end
  end

  describe "#convert_na_to_nil" do
    it "converts 'NA' values in hashes in arrays" do
      res = client.convert_na_to_nil([4, {foo: 'NA'}])
      expect(res[1][:foo]).to be_nil
    end

    it "converts 'NA' values in arrays in hashes" do
      res = client.convert_na_to_nil(foo: [1, 'NA'])
      expect(res[:foo][1]).to be_nil
    end

    it 'leaves other values alone' do
      res = client.convert_na_to_nil(foo: [1, 'NOTNA'])
      expect(res[:foo][1]).to eq 'NOTNA'
    end
  end

  describe '#function_url' do
    before { allow(client).to receive(:package_url).and_return '<package url>' }

    subject { client.send(:function_url, 'some_package', 'some_function', :kees, false, :json) }

    it { is_expected.to eq '<package url>/R/some_function/json' }
  end

  describe '#package_url' do
    let(:from_github) { false }

    subject { client.send(:package_url, 'some_package', user, from_github) }

    context ':system user' do
      let(:user) { :system }
      it { is_expected.to eq '/library/some_package' }
    end

    context 'other user' do
      let(:user) { :kees }

      context 'package is from GitHub' do
        let(:from_github) { true }
        it { is_expected.to eq '/github/kees/some_package' }
      end

      context 'other source' do
        it { is_expected.to eq '/user/kees/library/some_package' }
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
