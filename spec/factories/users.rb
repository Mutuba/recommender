# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::TvShows::GameOfThrones.character }

    trait :with_movie_likes do
      after(:create) do |user|
        movies = [
          "Avengers: Infinity War",
          "Star Wars: The Force Awakens",
          "Marvel’s The Avengers",
          "Star Wars: The Last Jedi",
          "The Dark Knight",
          "Beauty and the Beast",
          "Finding Dory",
          "Pirates of the Caribbean: Dead Man’s Chest"
        ]

        movies.each do |movie_name|
          movie = Movie.find_or_create_by(name: movie_name)
          user.movie_likes.create(movie: movie)
        end
      end
    end
  end
end
