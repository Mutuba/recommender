# frozen_string_literal: true

FactoryBot.define do
  factory :movie do
    name { Faker::Movie.title }
  end
end