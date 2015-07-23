require "spec_helper"

describe Configurator::SettingsParser do
  subject {
    Configurator::SettingsParser.new
  }

  describe "#parse()" do
    it "converts a Hash to an OpenStruct" do
      output = subject.parse({"one" => 1, "two" => 2, "three" => 3})
      expect(output.class).to eq(OpenStruct)
      expect(output.one).to eq(1)
      expect(output.two).to eq(2)
      expect(output.three).to eq(3)
    end

    it "acts recursive on all Hashes contained within the specified one" do
      output = subject.parse({one: {two: {three: 3}}})
      expect(output.one.class).to eq(OpenStruct)
      expect(output.one.two.class).to eq(OpenStruct)
      expect(output.one.two.three).to eq(3)
    end

    it "adds an #empty?() method to the OpenStructs it generates" do
      output = subject.parse({one: {two: {}}})
      expect(output.one.empty?).to eq(false)
      expect(output.one.two.empty?).to eq(true)
    end

    it "adds an #include?() method to the OpenStructs it generates" do
      output = subject.parse({one: 1})
      expect(output.include?(:one)).to eq(true)
      expect(output.include?(:two)).to eq(false)
    end
  end
end
