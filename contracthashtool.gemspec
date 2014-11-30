# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contracthashtool/version'

Gem::Specification.new do |spec|
  spec.name          = "contracthashtool"
  spec.version       = Contracthashtool::VERSION
  spec.authors       = ["Andy Alness"]
  spec.email         = ["andy.alness@gmail.com"]
  spec.summary       = %q{Ruby port of contracthashtool}
  spec.description   = %q{Ruby port of Blockstream's contracthashtool for federated peg support}
  spec.homepage      = "https://github.com/aalness/contracthashtool-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "bitcoin-ruby", "~> 0.0", ">= 0.0.6"
  spec.add_dependency "ffi", "~> 1.9"
end
