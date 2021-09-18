# frozen_string_literal: true

require_relative "lib/cobhan/version"

Gem::Specification.new do |spec|
  spec.name          = "cobhan"
  spec.version       = Cobhan::VERSION
  spec.authors       = [""]
  spec.email         = [""]

  spec.summary       = "Wrapper sample for Go c-shared build mode"
  spec.description   = "Wrapper sample for Go c-shared build mode"
  spec.homepage      = 'https://github.com/jgowdy/cobhan'
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jgowdy/cobhan"
  spec.metadata["changelog_uri"] = "https://github.com/jgowdy/cobhan/tree/main/ruby-ffi/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(File.expand_path(__dir__)) do
  #   `git ls-files -z`.split("\x0").reject do |f|
  #     (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
  #   end
  # end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi",    "~> 1.15.4"

  spec.add_development_dependency "rspec",    "~> 3.10.0"
end
