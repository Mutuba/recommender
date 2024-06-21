# frozen_string_literal: true
# spec/recommender/recommendation_spec.rb

require_relative "../spec_helper"

RSpec.describe Recommender::Recommendation, type: :module do
  describe "#recommendations ThroughReflection" do
    let(:first_user_with_movies) { create(:user, :with_movie_likes) }
    let(:second_user_with_movies) { create(:user, :with_movie_likes) }
    let(:third_user_with_movies) { create(:user, :with_movie_likes) }
    let(:first_movie) { create(:movie, name: "Stranger Things") }
    let(:second_movie) { create(:movie, name: "3 Body Problem") }

    it "has a version number" do
      expect(Recommender::VERSION).not_to be nil
    end
    it "returns recommended movies based on similarity measures" do
      first_user_with_movies.movies << first_movie
      first_user_with_movies.movies << second_movie
      recommendations = second_user_with_movies.recommendations
      recommended_movies = recommendations.map { |recommendation| recommendation.first }
      expect(recommended_movies).to include(first_movie)
      expect(recommended_movies).to include(second_movie)
    end

    it "returns no recommendations if there are no similar users" do
      third_user = create(:user)
      expect(third_user.recommendations).to be_empty
    end

    it "returns no recommendations if the user has no liked movies" do
      new_user = create(:user)
      expect(new_user.recommendations).to be_empty
    end

    it "does not include duplicate movies in recommendations" do
      first_user_with_movies.movies << first_movie
      first_user_with_movies.movies << second_movie
      recommendations = second_user_with_movies.recommendations
      recommended_movie_ids = recommendations.map { |recommendation| recommendation.first.id }
      expect(recommended_movie_ids.uniq.size).to eq(recommended_movie_ids.size)
    end

    it "respects the maximum number of recommendations limit" do
      first_user_with_movies.movies << first_movie
      first_user_with_movies.movies << second_movie
      recommendations = second_user_with_movies.recommendations(results: 1)
      expect(recommendations.size).to eq(1)
    end

    it "distributes similarity scores correctly" do
      first_user_with_movies.movies << first_movie
      first_user_with_movies.movies << second_movie
      third_user_with_movies.movies << second_movie
      recommendations = second_user_with_movies.recommendations()
      expect(recommendations.size).to eq(2)
      # Extract the ratings from the recommendations
      recommended_movie_ratings = recommendations.map { |_, rating| [ rating] }.flatten
      # Ensure the ratings are not the same
      expect(recommended_movie_ratings[1]).not_to eq(recommended_movie_ratings[0])
      expect(recommended_movie_ratings[0] > recommended_movie_ratings[1]).to be(true)
      # Check that the second_movie appears first in the rating list
      expect(recommendations[0][0]).to eq(second_movie)
    end

    it "handles edge cases gracefully" do
      single_user = create(:user, :with_movie_likes)
      expect(single_user.recommendations).to be_empty

      empty_system = User.destroy_all
      new_user = create(:user)
      expect(new_user.recommendations).to be_empty
    end
  end

  describe "#recommendations HasAndBelongsToManyReflection" do
    let!(:first_user) { create(:user) }
    let!(:second_user) { create(:user) }
    let(:first_album) { create(:album, :with_default_names) }
    let(:second_album) { create(:album, :with_default_names) }
    let(:third_album) { create(:album, :with_default_names) }
    let(:latest_album) { create(:album, name: "CRASH") }
    let(:trending_album) { create(:album, name: "Gold: Lionel Richie / Commodores") }

    before do
      first_user.albums << first_album
      first_user.albums << second_album
      first_user.albums << trending_album
      second_user.albums << first_album
      second_user.albums << second_album
    end
    
    it "returns recommended albums based on similarity measures" do
      recommendations = trending_album.recommendations
      album_user_recommendations = recommendations.map { |recommendation| recommendation.first }
      expect(album_user_recommendations).to include(second_user)
    end
  end
end