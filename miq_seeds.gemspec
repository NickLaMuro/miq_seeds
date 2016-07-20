# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'miq_seeds/version'

Gem::Specification.new do |spec|
  spec.name          = "miq_seeds"
  spec.version       = MiqSeeds::VERSION
  spec.authors       = ["Nick LaMuro"]
  spec.email         = ["nicklamuro@gmail.com"]

  spec.summary       = "Database seeds and generators for the ManageIQ application"
  spec.description   = "Database seeds and generators for the ManageIQ application"
  spec.homepage      = "http://github.com/NickLaMuro/miq_seeds"

  spec.files         = Dir["lib/**/*", "bin/*"]
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
