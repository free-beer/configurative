# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'configurative/version'

Gem::Specification.new do |spec|
  spec.name          = "configurative"
  spec.version       = Configurative::VERSION
  spec.authors       = ["Peter Wood"]
  spec.email         = ["peter.wood@longboat.com"]
  spec.summary       = %q{A library for handling Ruby configuration settings.}
  spec.description   = %q{A library for handling Ruby configuration settings. Inspired by the Settingslogic library but providing some additional functionality.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.3"

  spec.add_dependency "mime-types", "~> 3.3"
end
