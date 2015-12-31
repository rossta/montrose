# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "montrose/version"

Gem::Specification.new do |spec|
  spec.name          = "montrose"
  spec.version       = Montrose::VERSION
  spec.authors       = ["Ross Kaffenberger"]
  spec.email         = ["rosskaff@gmail.com"]

  spec.summary       = "Recurring events in Ruby"
  spec.description   = "A library for specifying, quering, and enumerating recurring events for calendars in Ruby."
  spec.homepage      = "https://github.com/rossta/montrose"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.1.0"

  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "m"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "timecop"
end
