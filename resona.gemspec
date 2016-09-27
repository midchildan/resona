# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resona/version'

Gem::Specification.new do |spec|
  spec.name          = "resona"
  spec.version       = Resona::VERSION
  spec.authors       = ["midchildan"]
  spec.email         = ["midchildan+rubygems@gmail.com"]

  spec.summary       = %q{Generates Homebrew stanzas for gem dependencies.}
  spec.homepage      = "https://github.com/midchildan/resona"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
