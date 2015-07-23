#! /usr/bin/env ruby
#
# Copyright (c), 2015 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

module Configurator
  class SettingsParser
    def initialize(options={})
      @options = {}.merge(options)
    end

    def parse(content)
      parse_hash(content)
    end

  private

    def parse_hash(hash)
      output = hash.inject(OpenStruct.new) do |object, entry|
        object[entry[0].to_sym] = (entry[1].kind_of?(Hash) ? parse_hash(entry[1]) : entry[1])
        object
      end
      output.define_singleton_method(:empty?) {output.to_h.empty?}
      output.define_singleton_method(:include?) {|key| output.to_h.include?(key)}
      output
    end
  end
end
