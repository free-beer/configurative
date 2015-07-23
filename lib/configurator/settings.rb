#! /usr/bin/env ruby
#
# Copyright (c), 2015 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

module Configurator
  class Settings
    @@options   = {}
    @@instances = {}

    def initialize(options={})
      @settings = nil
      self.class.options_for(self.class).merge!(options)
    end

    def self.instance
      instance_for(self)
    end

    def [](key)
      self.class[key]
    end

    def []=(key, value)
      self.class[key] = value
    end

    def fetch(key, alternative=nil)
      self.class.fetch(key, alternative)
    end

    def include?(key)
      self.class.include?(key)
    end

    def empty?
      self.class.empty?
    end

    def self.[](key)
      instance_for(self)[key]
    end

    def self.[]=(key, value)
      instance_for(self)[key] = value
    end

    def self.fetch(key, alternative=nil)
      self[key] || alternative
    end

    def self.include?(key)
      instance_for(self).include?(key)
    end

    def self.empty?
      instance_for(self).empty?
    end

    def respond_to?(method_name, include_private=false)
      self.class.instance_for?(self.class).include?(property_name(method_name)) || super
    end

    def method_missing(method_name, *arguments, &block)
      self.class.method_missing(method_name, *arguments, &block) || super
    end

    def self.reset(full=false)
      @@instances = {}
      @@options.delete(self) if full
    end

    def self.respond_to?(method_name, include_private=false)
      instance_for(self).include?(property_name(method_name)) || super
    end

    def self.method_missing(method_name, *arguments, &block)
      data = instance_for(self)
      if method_name[-1,1] == "="
        data[property_name(method_name)] = arguments.first
      else
        if data.include?(method_name)
          data[method_name]
        else
          super
        end
      end
    end

    def self.files(*files)
      options_for(self)[:files] = files
    end

    def self.sources(*files)
      files(*files)
    end

    def self.environment(setting)
      options_for(self)[:environment] = setting
    end

    def self.namespace(setting)
      environment(setting)
    end

    def self.section(setting)
      options_for(self)[:section] = setting
    end

    def self.load(*files)
      settings = nil
      path     = find_file(*files)
      if path
        begin
          settings          = SettingsLoader.new(options).load!(path)
          @@instances[self] = settings
        rescue => error
          # Deliberately ignored.
        end
      end
      settings
    end

    def self.load!(*files)
      settings = load(*files)
      raise ConfigurationError, "Unable to locate an accessible configuration file." if settings.nil?
      settings
    end

  private

    def options
      self.class.options
    end

    def self.options
      options_for(self)
    end

    def self.find_file(*paths)
      paths.find {|entry| File.exist?(entry) && File.file?(entry) && File.readable?(entry)}
    end

    def self.instance_for(klass, defaults={})
      if !@@instances.include?(klass)
        files             = options[:files] || []
        settings          = load(*files)
        parser            = SettingsParser.new(options_for(klass))
        @@instances[klass] = settings.nil? ? parser.parse(defaults) : settings
      end
      @@instances[klass]
    end

    def self.options_for(klass)
      if !@@options.include?(klass)
        @@options[klass] = {environment: (ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"),
                            section:     nil}
      end
      @@options[klass]
    end

    def self.property_name(name)
      (name.to_s[-1, 1] == "=" ? name.to_s[0...-1] : name.to_s).to_sym
    end
  end
end
