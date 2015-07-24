require "spec_helper"

describe Configurative::Settings do
  before do
    Configurative::Settings.reset
  end

  describe "when a source file is available" do
    subject {
      Configurative::Settings.new(files: [File.join(Dir.getwd, "spec", "data", "environment_test.yml")])
    }

    it "autoloads the files contents" do
      expect(subject[:section1].class).to eq(OpenStruct)
      expect(subject[:section2].class).to eq(OpenStruct)
      expect(subject[:section3].class).to eq(OpenStruct)
    end
  end

  describe "#[]()" do
    subject {
      Configurative::Settings.new
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
        expect(Configurative::Settings[:one]).to eq(1)
        expect(Configurative::Settings[:two]).to eq("Two")
        expect(Configurative::Settings[:three]).to eq(3)
      end

      it "returns nil if the requested value does not exist" do
        expect(Configurative::Settings[:non_existent]).to be_nil
      end
    end
  end

  describe "#[]=()" do
    subject {
      Configurative::Settings.new
    }

    describe "at the instance level" do
      it "assigns a value to a key" do
        subject[:value] = "Value"
        expect(subject.value).to eq("Value")
      end
    end


    describe "at the class level" do
      it "assigns a value to a key" do
        Configurative::Settings[:value] = "Value"
        expect(Configurative::Settings.value).to eq("Value")
      end
    end
  end

  describe "#fetch()" do
    subject {
      Configurative::Settings.new
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
        expect(Configurative::Settings.fetch(:one)).to eq(1)
        expect(Configurative::Settings.fetch(:two)).to eq("Two")
        expect(Configurative::Settings.fetch(:three)).to eq(3)
      end

      it "returns the alternative value if the requested value does not exist" do
        expect(Configurative::Settings.fetch(:non_existent)).to be_nil
        expect(Configurative::Settings.fetch(:non_existent, "blah")).to eq("blah")
      end
    end
  end

  describe "#include?()" do
    subject {
      Configurative::Settings.new
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
        expect(Configurative::Settings.include?(:one)).to eq(true)
      end

      it "returns false if the specified key does not exist" do
        expect(Configurative::Settings.include?(:blah)).to eq(false)
      end
    end
  end

  describe "#empty?()" do
    subject {
      Configurative::Settings.new
    }

    before do
      Configurative::Settings.reset(true)
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
        expect(Configurative::Settings.empty?).to eq(true)
      end

      it "returns false if at least one value has been set" do
        Configurative::Settings.one = 1
        expect(Configurative::Settings.empty?).to eq(false)
      end
    end
  end

  describe "derived classes" do
    describe "using the files setting" do
      class TestClass1 < Configurative::Settings
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
      class TestClass2 < Configurative::Settings
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
      class TestClass3 < Configurative::Settings
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
