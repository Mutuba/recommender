# frozen_string_literal: true

require "recommender"
require 'factory_bot_rails'
require "faker"
require 'database_cleaner/active_record'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../test_app/config/environment.rb', __FILE__)

factories_path = File.expand_path("../spec/factories/**/*.rb", __dir__)
Dir[factories_path].sort.each { |file| require file }
Dir[Rails.root.join('spec', '**', '*.rb')].sort.each { |file| require file }

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
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
