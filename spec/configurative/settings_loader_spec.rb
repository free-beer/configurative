require "spec_helper"

describe Configurative::SettingsParser do
  subject {
    Configurative::SettingsLoader.new
  }

  describe "#load!()" do
    describe "when loading a YAML file" do
      let(:path) {
        File.join(Dir.getwd, "spec", "data", "test.yml")
      }

      it "returns an OpenStruct containing the configuration data" do
        output = subject.load!(path)
        expect(output.class).to be(OpenStruct)
        expect(output.one.two.three).to eq(3)
      end
    end

    describe "when loading a JSON file" do
      let(:path) {
        File.join(Dir.getwd, "spec", "data", "test.json")
      }

      it "returns an OpenStruct containing the configuration data" do
        output = subject.load!(path)
        expect(output.class).to be(OpenStruct)
        expect(output.one.two.three).to eq(3)
      end
    end

    describe "when an alternative environment setting is available" do
      before do
        ENV['RACK_ENV'] = "production"
      end

      after do
        ENV['RACK_ENV'] = nil
      end

      let(:path) {
        File.join(Dir.getwd, "spec", "data", "environment_test.yml")
      }

      subject {
        Configurative::SettingsLoader.new(section: "section2")
      }

      it "picks up the settings for the specified environment" do
        output = subject.load!(path)
        expect(output.one).to be_nil
        expect(output.two).to be_nil
        expect(output.three).to be_nil
        expect(output.four).to eq(4)
        expect(output.five).to eq(5)
        expect(output.six).to eq(6)
      end

      it "still picks up the section setting" do
        ENV['RACK_ENV'] = nil
        output = subject.load!(path)
        expect(output.one).to eq(1)
        expect(output.two).to eq(2)
        expect(output.three).to eq(3)
      end

      it "returns the entire file contents when an environment that doesn't exist is specified" do
        ENV['RACK_ENV'] = "alternative"
        output = subject.load!(path)
        expect(output.development).not_to be_nil
        expect(output.production).not_to be_nil
      end
    end

    describe "when a section setting is specified" do
      let(:path) {
        File.join(Dir.getwd, "spec", "data", "section_test.yml")
      }

      subject {
        Configurative::SettingsLoader.new(section: "section2")
      }

      it "returns only the specified sections contents if it exists" do
        output = subject.load!(path)
        expect(output.one).to be_nil
        expect(output.two).to be_nil
        expect(output.three).to eq(3)
        expect(output.four).to eq(4)
        expect(output.five).to be_nil
        expect(output.six).to be_nil
      end

      it "returns the entire contents if a matching section does not exist" do
        output = Configurative::SettingsLoader.new(section: "blah").load!(path)
        expect(output.section1).not_to be_nil
        expect(output.section2).not_to be_nil
        expect(output.section3).not_to be_nil
      end
    end

    it "raises an exception if given a non-existent file name" do
      expect {
        subject.load!("blah.yml")
      }.to raise_exception(Configurative::ConfigurationError,
                           "Exception caught loading the 'blah.yml' configuration file.")
    end

    it "raises an exception if given an unsupported file type" do
      expect {
        subject.load!("blah.txt")
      }.to raise_exception(Configurative::ConfigurationError,
                           "Unsupported confguration file type 'text/plain' encountered.")
    end
  end

  describe "templated source file" do
    before do
      ENV["TEST_VALUE"] = "Testing Value"
    end

    subject {
      Configurative::SettingsLoader.new(section: "section2")
    }

    describe "from a YAML source" do
      let(:path) {
        File.join(Dir.getwd, "spec", "data", "template_test.yml")
      }

      it "loads and parses the template correctly" do
        output = subject.load!(path)
        expect(output.setting).to eq("Testing Value")
      end
    end


    describe "from a JSON source" do
      let(:path) {
        File.join(Dir.getwd, "spec", "data", "template_test.json")
      }

      it "loads and parses the template correctly" do
        output = subject.load!(path)
        expect(output.setting).to eq("Testing Value")
      end
    end
  end
end
