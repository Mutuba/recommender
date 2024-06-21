class User < ApplicationRecord
  include Recommender::Recommendation

  has_many :movie_likes, dependent: :destroy
  has_many :movies, through: :movie_likes
  has_and_belongs_to_many :albums

  validates :name, presence: true,  uniqueness: { case_sensitive: false }
  set_association :movies
end
