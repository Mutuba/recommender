class Album < ApplicationRecord
  include Recommender::Recommendation

  has_and_belongs_to_many :listeners, class_name: 'User'
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  set_associations listeners: 2.0
end
