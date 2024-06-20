# frozen_string_literal: true

# spec/recommender/recommendation_spec.rb
require_relative "../spec_helper"

RSpec.describe Recommender::Recommendation, type: :module do
  let(:first_user_with_movies) { create(:user, :with_movie_likes) }
  let(:second_user_with_movies) { create(:user, :with_movie_likes) }

  let(:movies) { create_list(:movie, 2)}

  describe "#recommendations" do
    it "has a version number" do
      expect(Recommender::VERSION).not_to be nil
    end
    it "returns recommended movies based on similarity measures" do
      # add two movies to the list of movies for first_user_with_movies
      first_user_with_movies.movies << movies
      # get second_user_with_movies recommendations
      recommendations = second_user_with_movies.recommendations
     # Extract the movies from the recommendations
     recommended_movies = recommendations.map { |recommendation| recommendation.first }
     # Check if the recommended movies include the movies
     movies.each do |movie|
       expect(recommended_movies).to include(movie)
     end
    end
  end
end
