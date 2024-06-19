class User < ApplicationRecord
  has_many :liked_movies, dependent: :destroy
  has_many :movies, through: :liked_movies

  validates :name, presence: true
end
