class Movie < ApplicationRecord
  has_many :liked_movies, dependent: :destroy
  has_many :users, through: :liked_movies
end
