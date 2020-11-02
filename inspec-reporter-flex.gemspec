require_relative "lib/inspec-reporter-flex/version"

Gem::Specification.new do |spec|
  spec.name          = "inspec-reporter-flex"
  spec.version       = InspecPlugins::FlexReporter::VERSION
  spec.authors       = ["Thomas Heinen"]
  spec.email         = ["theinen@tecracer.de"]
  spec.summary       = "InSpec Reporter for flexible, template-based reports"
  spec.description   = "Plugin for templated reports"
  spec.homepage      = "https://github.com/tecracer-chef/inspec-reporter-flex"
  spec.license       = "Apache-2.0"

  spec.files         = Dir["lib/**/**/**"]
  spec.files        += Dir["templates/**/**/**"]
  spec.files        += ["README.md", "CHANGELOG.md"]

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6"

  spec.add_development_dependency "bump", "~> 0.9"
  spec.add_development_dependency "chefstyle", "~> 0.14"
  spec.add_development_dependency "guard", "~> 2.16"
  spec.add_development_dependency "mdl", "~> 0.9"
  spec.add_development_dependency "rake", "~> 13.0"
end
