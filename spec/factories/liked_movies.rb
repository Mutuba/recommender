# frozen_string_literal: true

FactoryBot.define do
  factory :liked_movie do
    association :user
    association :movie
  end
end