# frozen_string_literal: true

require "recommender"
require 'factory_bot_rails'
require 'active_record'

# Load models
require_relative '../lib/recommender/user'
require_relative '../lib/recommender/movie'
require_relative '../lib/recommender/liked_movie'

# Set up ActiveRecord with an in-memory SQLite database
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

# Define schema
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.timestamps
  end

  create_table :movies do |t|
    t.string :title
    t.timestamps
  end

  create_table :liked_movies do |t|
    t.references :user, foreign_key: true
    t.references :movie, foreign_key: true
    t.timestamps
  end
end

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
