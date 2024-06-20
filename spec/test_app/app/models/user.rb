class User < ApplicationRecord
  include Recommender::Recommendation

  has_many :movie_likes, dependent: :destroy
  has_many :movies, through: :movie_likes

  validates :name, presence: true,  uniqueness: { case_sensitive: false }
  set_association :movies
end
