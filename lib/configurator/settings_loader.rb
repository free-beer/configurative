#! /usr/bin/env ruby
#
# Copyright (c), 2015 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

module Configurator
  class SettingsLoader
    def initialize(options={})
      @options = {}.merge(options)
    end

    def load!(path)
      type = MIME::Types.type_for(path).first.content_type
      case type
        when "application/json"
          load_json_file!(path)
        when "text/x-yaml"
          load_yaml_file!(path)
        else
          raise ConfigurationError, "Unsupported confguration file type '#{type}' encountered."
      end
    end

  private

    def environment
      (@options[:environment] || ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development")
    end

    def section
      (@options[:section] || nil)
    end

    def load_yaml_file!(path)
      extract_settings(YAML.load_file(path))
    rescue => error
      raise ConfigurationError.new("Exception caught loading the '#{path}' configuration file.", error)
    end

    def load_json_file!(path)
      extract_settings(JSON.parse(File.read(path)))
    rescue => error
      raise ConfigurationError.new("Exception caught loading the '#{path}' configuration file.", error)
    end

    def extract_settings(input)
      settings = {}.merge(input)
      settings = settings[environment] if settings.include?(environment)
      settings = settings[section] if section && settings.include?(section)
      SettingsParser.new(@options).parse(settings)
    end
  end
end
