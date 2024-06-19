# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::TvShows::GameOfThrones.character }

    trait :with_movies do
      after :create do |user|
        create_list :liked_movie, 5, user: user, movie: FactoryBot.create(:movie, name: Faker::Movie.title)
      end
    end
  end
end
