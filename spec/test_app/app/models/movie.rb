class Movie < ApplicationRecord
  has_many :movie_likes, dependent: :destroy
  has_many :users, through: :movie_likes
end
