class User < ApplicationRecord
  include Recommender::Recommendation

  has_many :liked_movies, dependent: :destroy
  has_many :movies, through: :liked_movies

  validates :name, presence: true

  set_association :movies
end
