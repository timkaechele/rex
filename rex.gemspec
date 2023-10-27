# frozen_string_literal: true

require_relative "lib/rex/version"

Gem::Specification.new do |spec|
  spec.name = "rex"
  spec.version = Rex::VERSION
  spec.authors = ["Tim Kächele"]
  spec.email = ["mail@timkaechele.me"]

  spec.summary = "Order book and matching engine implementation"
  spec.description = "A simple limit order book with a matching engine implementation"
  spec.homepage = "https://git.timkaechele.me/rex"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rbtree", "~> 0.4.6"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
