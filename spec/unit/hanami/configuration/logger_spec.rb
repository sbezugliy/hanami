# frozen_string_literal: true

require "hanami/configuration/logger"
require "logger"

RSpec.describe Hanami::Configuration::Logger do
  subject { described_class.new(application_name: application_name, env: env) }
  let(:application_name) { -> { :my_app } }
  let(:env) { :development }

  describe "#logger_class" do
    it "defaults to Hanami::Logger" do
      expect(subject.logger_class).to eql Hanami::Logger
    end

    it "can be changed to another class" do
      another_class = Class.new

      expect { subject.logger_class = another_class }
        .to change { subject.logger_class }
        .to(another_class)
    end
  end

  describe "#application_name" do
    before do
      subject.finalize!
    end

    it "defaults returns application name" do
      expect(subject.application_name).to eq(application_name.call)
    end
  end

  describe "#level" do
    it "defaults to :debug" do
      expect(subject.level).to eq(:debug)
    end

    context "when :production environment" do
      let(:env) { :production }

      it "returns :info" do
        expect(subject.level).to eq(:info)
      end
    end
  end

  describe "#level=" do
    it "a value" do
      expect { subject.level = :warn }
        .to change { subject.level }
        .to(:warn)
    end
  end

  describe "#stream" do
    it "defaults to $stdout" do
      expect(subject.stream).to eq($stdout)
    end

    context "when :test environment" do
      let(:env) { :test }

      it "returns a file" do
        expected = File.join("log", "test.log")

        expect(subject.stream).to eq(expected)
      end
    end
  end

  describe "#stream=" do
    it "accepts a IO object or a path to a file" do
      expect { subject.stream = "/dev/null" }
        .to change { subject.stream }
        .to("/dev/null")
    end
  end

  describe "#formatter" do
    it "defaults to nil" do
      expect(subject.formatter).to eq(nil)
    end

    context "when :production environment" do
      let(:env) { :production }

      it "returns :json" do
        expect(subject.formatter).to eq(:json)
      end
    end
  end

  describe "#formatter=" do
    it "accepts a formatter" do
      expect { subject.formatter = :json }
        .to change { subject.formatter }
        .to(:json)
    end
  end

  describe "#colors" do
    it "defaults to nil" do
      expect(subject.colors).to eq(nil)
    end

    context "when :test environment" do
      let(:env) { :test }

      it "returns false" do
        expect(subject.colors).to eq(false)
      end
    end

    context "when :production environment" do
      let(:env) { :production }

      it "returns false" do
        expect(subject.colors).to eq(false)
      end
    end
  end

  describe "#colors=" do
    it "accepts a value" do
      expect { subject.colors = false }
        .to change { subject.colors }
        .to(false)
    end
  end

  describe "#filters" do
    it "defaults to a standard array of sensitive param names" do
      expect(subject.filters).to include(*%w[_csrf password password_confirmation])
    end

    it "can have other params names added" do
      expect { subject.filters << "secret" }
        .to change { subject.filters }
        .to array_including("secret")

      expect { subject.filters += ["yet", "another"] }
        .to change { subject.filters }
        .to array_including(["yet", "another"])
    end

    it "can be changed to another array" do
      expect { subject.filters = ["secret"] }
        .to change { subject.filters }
        .to ["secret"]
    end
  end

  describe "#options" do
    it "defaults to empty array" do
      expect(subject.options).to eq([])
    end
  end

  describe "#options=" do
    it "accepts value" do
      subject.options = expected = "daily"

      expect(subject.options).to eq([expected])
    end

    it "accepts values" do
      subject.options = expected = [0, 1048576]

      expect(subject.options).to eq(expected)
    end
  end
end


RSpec.describe Hanami::Configuration do
  subject(:config) { described_class.new(application_name: application_name, env: env) }
  let(:application_name) { "SOS::Application" }
  let(:env) { :development }

  describe "#logger" do
    before do
      config.inflections do |inflections|
        inflections.acronym "SOS"
      end

      config.logger.finalize!
    end

    describe "#application_name" do
      it "defaults to Hanami::Configuration#application_name" do
        expect(config.logger.application_name).to eq(config.application_name)
      end
    end
  end

  describe "#logger_instance" do
    it "defaults to an Hanami::Logger instance, based on the default logger settings" do
      expect(config.logger_instance).to be_an_instance_of config.logger.logger_class
      expect(config.logger_instance.level).to eq Logger::DEBUG
    end

    it "can be changed to a pre-initialized instance via #logger=" do
      logger_instance = Object.new

      expect { config.logger = logger_instance }
        .to change { config.logger_instance }
        .to logger_instance
    end
  end
end
