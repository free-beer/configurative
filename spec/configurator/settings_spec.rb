require "spec_helper"

describe Configurator::Settings do
  before do
    Configurator::Settings.reset
  end

  describe "when a source file is available" do
    subject {
      Configurator::Settings.new(files: [File.join(Dir.getwd, "spec", "data", "environment_test.yml")])
    }

    it "autoloads the files contents" do
      expect(subject[:section1].class).to eq(OpenStruct)
      expect(subject[:section2].class).to eq(OpenStruct)
      expect(subject[:section3].class).to eq(OpenStruct)
    end
  end

  describe "#[]()" do
    subject {
      Configurator::Settings.new
    }

    before do
      subject.one   = 1
      subject.two   = "Two"
      subject.three = 3
    end

    describe "at the instance level" do
      it "returns the requested value if it exists" do
        expect(subject[:one]).to eq(1)
        expect(subject[:two]).to eq("Two")
        expect(subject[:three]).to eq(3)
      end

      it "returns nil if the requested value does not exist" do
        expect(subject[:non_existent]).to be_nil
      end
    end

    describe "at the class level" do
      it "returns the requested value if it exists" do
        expect(Configurator::Settings[:one]).to eq(1)
        expect(Configurator::Settings[:two]).to eq("Two")
        expect(Configurator::Settings[:three]).to eq(3)
      end

      it "returns nil if the requested value does not exist" do
        expect(Configurator::Settings[:non_existent]).to be_nil
      end
    end
  end

  describe "#[]=()" do
    subject {
      Configurator::Settings.new
    }

    describe "at the instance level" do
      it "assigns a value to a key" do
        subject[:value] = "Value"
        expect(subject.value).to eq("Value")
      end
    end


    describe "at the class level" do
      it "assigns a value to a key" do
        Configurator::Settings[:value] = "Value"
        expect(Configurator::Settings.value).to eq("Value")
      end
    end
  end

  describe "#fetch()" do
    subject {
      Configurator::Settings.new
    }

    before do
      subject.one   = 1
      subject.two   = "Two"
      subject.three = 3
    end

    describe "at the instance level" do
      it "returns the requested value if it exists" do
        expect(subject.fetch(:one)).to eq(1)
        expect(subject.fetch(:two)).to eq("Two")
        expect(subject.fetch(:three)).to eq(3)
      end

      it "returns the alternative value if the requested value does not exist" do
        expect(subject.fetch(:non_existent)).to be_nil
        expect(subject.fetch(:non_existent, "blah")).to eq("blah")
      end
    end

    describe "at the class level" do
      it "returns the requested value if it exists" do
        expect(Configurator::Settings.fetch(:one)).to eq(1)
        expect(Configurator::Settings.fetch(:two)).to eq("Two")
        expect(Configurator::Settings.fetch(:three)).to eq(3)
      end

      it "returns the alternative value if the requested value does not exist" do
        expect(Configurator::Settings.fetch(:non_existent)).to be_nil
        expect(Configurator::Settings.fetch(:non_existent, "blah")).to eq("blah")
      end
    end
  end

  describe "#include?()" do
    subject {
      Configurator::Settings.new
    }

    before do
      subject.one = 1
    end

    describe "at the instance level" do
      it "returns true if the specified key exists" do
        expect(subject.include?(:one)).to eq(true)
      end

      it "returns false if the specified key does not exist" do
        expect(subject.include?(:blah)).to eq(false)
      end
    end

    describe "at the class level" do
      it "returns true if the specified key exists" do
        expect(Configurator::Settings.include?(:one)).to eq(true)
      end

      it "returns false if the specified key does not exist" do
        expect(Configurator::Settings.include?(:blah)).to eq(false)
      end
    end
  end

  describe "#empty?()" do
    subject {
      Configurator::Settings.new
    }

    before do
      Configurator::Settings.reset(true)
    end

    describe "at the instance level" do
      it "returns true if no values have been set" do
        expect(subject.empty?).to eq(true)
      end

      it "returns false if at least one value has been set" do
        subject.one = 1
        expect(subject.empty?).to eq(false)
      end
    end

    describe "at the class level" do
      it "returns true if no values have been set" do
        expect(Configurator::Settings.empty?).to eq(true)
      end

      it "returns false if at least one value has been set" do
        Configurator::Settings.one = 1
        expect(Configurator::Settings.empty?).to eq(false)
      end
    end
  end

  describe "derived classes" do
    describe "using the files setting" do
      class TestClass1 < Configurator::Settings
        files File.join(Dir.getwd, "spec", "data", "non_existent.yml"),
              File.join(Dir.getwd, "spec", "data", "test.yml")
      end

      subject {
        TestClass1
      }

      it "loads data from the first matching, readable file it finds" do
        expect(subject.empty?).to eq(false)
        expect(subject.include?(:one)).to eq(true)
      end
    end

    describe "using the environment setting" do
      class TestClass2 < Configurator::Settings
        files File.join(Dir.getwd, "spec", "data", "environment_test.yml")
        environment "production"
      end

      subject {
        TestClass2
      }

      it "loads data from the correct section of the configuration file" do
        expect(subject.empty?).to eq(false)
        expect(subject.include?(:section2)).to eq(true)
      end
    end

    describe "using the section setting" do
      class TestClass3 < Configurator::Settings
        files File.join(Dir.getwd, "spec", "data", "section_test.yml")
        section "section3"
      end

      subject {
        TestClass3
      }

      it "loads data from the correct section of the configuration file" do
        expect(subject.empty?).to eq(false)
        expect(subject.instance.to_h.size).to eq(2)
        expect(subject.include?(:five)).to eq(true)
      expect(subject.include?(:six)).to eq(true)
      end
    end
  end
end
