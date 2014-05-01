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
  
  describe "#graphics" do
    let(:location) { "https://public.opencpu.org/ocpu/tmp/x0f6a825bad/" }
    let(:resources) do
      [
        "/ocpu/tmp/x0f6a825bad/R/.val",
        "/ocpu/tmp/x0f6a825bad/graphics/1",
        "/ocpu/tmp/x0f6a825bad/source",
        "/ocpu/tmp/x0f6a825bad/console",
        "/ocpu/tmp/x0f6a825bad/info"
      ]
    end
    let(:delayed_calculation) { described_class.new location, resources }
    it 'defines methods to access graphic functions' do
      VCR.use_cassette :get_graphics do
        expect { delayed_calculation.graphics }.not_to raise_error OpenCPU::ResponseNotAvailableError
        expect { delayed_calculation.stdout }.to raise_error OpenCPU::ResponseNotAvailableError
      end
    end

    it "returns a SVG by default" do
      VCR.use_cassette :get_graphics do
        expect(delayed_calculation.graphics).to include 'svg xmlns'
      end
    end

    it "can return a PNG" do
      VCR.use_cassette :get_graphics do
        expect(delayed_calculation.graphics(:png)).to include 'PNG'
      end
    end

    it "does not support formats except PNG and SVG" do
      VCR.use_cassette :get_graphics do
        expect { delayed_calculation.graphics(:svg) }.not_to raise_error OpenCPU::UnsupportedFormatError
        expect { delayed_calculation.graphics(:png) }.not_to raise_error OpenCPU::UnsupportedFormatError
        expect { delayed_calculation.graphics(:foo) }.to raise_error OpenCPU::UnsupportedFormatError
        expect { delayed_calculation.graphics(:bar) }.to raise_error OpenCPU::UnsupportedFormatError
      end
    end
  end

  describe 'standard getters' do
    let(:location) { 'https://public.opencpu.org/ocpu/tmp/x04956b9f9b/' }
    let(:resources) do
      [
        "/ocpu/tmp/x04956b9f9b/R/.val",
        "/ocpu/tmp/x04956b9f9b/stdout",
        "/ocpu/tmp/x04956b9f9b/warnings",
        "/ocpu/tmp/x04956b9f9b/source",
        "/ocpu/tmp/x04956b9f9b/console",
        "/ocpu/tmp/x04956b9f9b/info"
      ]
    end
    let(:delayed_calculation) { described_class.new location, resources }

    describe '#value' do
      it "returns raw R calculation result" do
        VCR.use_cassette :get_value do
          expect(delayed_calculation.value).to eq '[1] "22e2a7a268bf076801eefe7cd0119bb9"'
        end
      end
    end

    describe '#stdout' do
      it "returns cached stdout" do
        VCR.use_cassette :get_stdout do
          expect(delayed_calculation.stdout).to eq '[1] "22e2a7a268bf076801eefe7cd0119bb9"'
        end
      end
    end

    describe '#warnings' do
      it 'returns cached warnings' do
        VCR.use_cassette :get_warnings do
          expect(delayed_calculation.warnings).to include("the condition has length > 1")
        end
      end      
    end

    describe '#info' do
      it 'returns cached info' do
        VCR.use_cassette :get_info do
          expect(delayed_calculation.info).to include("R version")
        end
      end
    end

    describe "#console" do
      it 'returns cached console input' do
        VCR.use_cassette :get_console do
          expect(delayed_calculation.console).to include("hmac(key = \"baz\", object = \"qux\"")
        end
      end
    end
  end
end
