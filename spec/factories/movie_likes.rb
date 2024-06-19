# frozen_string_literal: true

FactoryBot.define do
  factory :movie_like do
    association :user
    association :movie
  end
end