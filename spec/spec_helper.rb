# frozen_string_literal: true

require "recommender"
require 'factory_bot_rails'

# Load models
require_relative 'test_app/app/models/user.rb'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

# Require RSpec and its configuration
require 'rspec/rails'


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.include FactoryBot::Syntax::Methods

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    # Load factories and any other setup needed before tests run
    FactoryBot.find_definitions
  end

  config.before(:each) do
    # Ensure a clean state for each test
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
