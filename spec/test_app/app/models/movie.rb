class Movie < ApplicationRecord
  has_many :movie_likes, dependent: :destroy
  has_many :users, through: :movie_likes

  validates :name, presence: true
  validates :name, presence: true,  uniqueness: { case_sensitive: false }
end
