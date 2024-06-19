# frozen_string_literal: true

# spec/recommender/recommendation_spec.rb
require_relative "../spec_helper"

RSpec.describe Recommender::Recommendation, type: :module do

  let(:user_with_movies) { create(:user, :with_movies) }
  let(:movies) { create_list(:movie, 10)}
  # let(:user) { User.create(id: 1, movies: ["Movie A", "Movie B"]) }

  describe "#recommendations" do
    it "has a version number" do
      expect(Recommender::VERSION).not_to be nil
    end
    it "returns recommended movies based on similarity measures" do
      binding.pry
      other_user = User.create(id: 2, movies: ["Movie B", "Movie C"])
      allow(User).to receive(:where).and_return([other_user])

      recommendations = user.recommendations
      expect(recommendations).to eq([["Movie C", some_weight]]) # Adjust as needed based on your expectations
    end
  end
end
