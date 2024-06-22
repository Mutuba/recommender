class Album < ApplicationRecord
  include Recommender::Recommendation

  has_and_belongs_to_many :users
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  set_associations users: 2.0
end
