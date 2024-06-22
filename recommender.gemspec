# frozen_string_literal: true

require_relative "lib/recommender/version"

Gem::Specification.new do |spec|
  spec.name = "recommender"
  spec.version = Recommender::VERSION
  spec.authors = ["Mutuba"]
  spec.email = ["danielmutubait@gmail.com"]
  spec.summary = "A gem for providing recommendations using various similarity measures"
  spec.description = "This gem provides recommendations by calculating similarity scores using the Jaccard Index, Dice-Sørensen Coefficient, and collaborative filtering."
  spec.homepage = "https://github.com/Mutuba/recommender"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Mutuba/recommender"
  spec.metadata["changelog_uri"] = "https://github.com/Mutuba/recommender/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?('recommender-') ||  # Exclude built gem files
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end

  spec.test_files  = Dir['spec/**/*']
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.9.0"
  spec.add_development_dependency  "pg", "~> 1.1"
  spec.add_development_dependency "factory_bot_rails", "~> 6.2"
  spec.add_runtime_dependency 'rails', '~> 7.1.3'
  spec.add_runtime_dependency 'database_cleaner-active_record', '~> 2.0'
  spec.add_development_dependency 'pry-rails', '~> 0.3'
  spec.add_runtime_dependency 'faker', '~> 2.21'
end
