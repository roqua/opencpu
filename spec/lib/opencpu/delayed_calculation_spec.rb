require 'spec_helper'

describe OpenCPU::DelayedCalculation do

  let(:delayed_calculation) { described_class.new 'foo' }

  describe "initializes" do
    it "without resources" do
      delayed_calculation = described_class.new 'foo'
      expect(delayed_calculation.available_resources).to eq Hash.new
    end

    let(:resources) do
      [
        '/foo/bar',
        '/foo/baz'
      ]
    end
    let(:parsed_resources) do
      {
        bar: URI.parse('https://opencpu.org/foo/bar'),
        baz: URI.parse('https://opencpu.org/foo/baz')
      }
    end
    it "with resources" do
      delayed_calculation = described_class.new 'https://opencpu.org/foo/', resources
      expect(delayed_calculation.available_resources).to eq parsed_resources
    end
  end

  let(:location) { "https://public.opencpu.org/ocpu/tmp/x09dd995a16/" }
  let(:delayed_calculation) { OpenCPU::client.prepare('animation', 'flip.coin') }

  describe "#graphics" do

    it 'defines methods to access graphic functions' do
      VCR.use_cassette :animation_flip_coin, record: :new_episodes do
        expect { delayed_calculation.graphics }.not_to raise_error
        expect { delayed_calculation.stdout }.to raise_error OpenCPU::ResponseNotAvailableError
      end
    end

    it "returns a SVG by default" do
      VCR.use_cassette :animation_flip_coin, record: :new_episodes do
        expect(delayed_calculation.graphics).to include 'svg xmlns'
      end
    end

    it "can return a PNG" do
      VCR.use_cassette :animation_flip_coin, record: :new_episodes do
        expect(delayed_calculation.graphics(0, :png)).to include 'PNG'
      end
    end

    it "does not support formats except PNG and SVG" do
      VCR.use_cassette :animation_flip_coin, record: :new_episodes do
        expect { delayed_calculation.graphics(0, :svg) }.not_to raise_error
        expect { delayed_calculation.graphics(0, :png) }.not_to raise_error
        expect { delayed_calculation.graphics(0, :foo) }.to raise_error OpenCPU::UnsupportedFormatError
        expect { delayed_calculation.graphics(0, :bar) }.to raise_error OpenCPU::UnsupportedFormatError
      end
    end

    it 'can handle multiple graphic output' do

    end
  end

  describe 'standard getters' do
    describe '#value' do
      it "returns raw R calculation result" do
        VCR.use_cassette :animation_flip_coin, record: :new_episodes do
          expect(delayed_calculation.value).to include "$freq"
        end
      end
    end

    describe '#stdout' do
      it "returns cached stdout" do
        VCR.use_cassette :animation_flip_coin, record: :new_episodes do
          expect { delayed_calculation.stdout }.to raise_error OpenCPU::ResponseNotAvailableError
        end
      end
    end

    describe '#warnings' do
      it 'returns cached warnings' do
        VCR.use_cassette :animation_flip_coin, record: :new_episodes do
          expect { delayed_calculation.warnings }.to raise_error OpenCPU::ResponseNotAvailableError
        end
      end
    end

    describe '#info' do
      it 'returns cached info' do
        VCR.use_cassette :animation_flip_coin, record: :new_episodes do
          expect(delayed_calculation.info).to include("R version")
        end
      end
    end

    # describe "#console" do
    #   it 'returns cached console input' do
    #     VCR.use_cassette :animation_flip_coin do
    #       expect(delayed_calculation.console).to include("hmac(key = \"baz\", object = \"qux\"")
    #     end
    #   end
    # end
  end
end
