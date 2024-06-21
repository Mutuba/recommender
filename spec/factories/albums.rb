# frozen_string_literal: true

FactoryBot.define do
  factory :album do
    name { Faker::Music.album }
    trait :with_default_names do
      album_names = [
        "The Very Best of Kool & The Gang",
        "Born in the Wild",
        "Where the Butterflies Go in the Rain",
        "All the Best: The Hits",
        "On the Radio: Greatest Hits, Vol. I & II",
        "Confessions (Expanded Edition)",
        "The Best Of Bill Withers: Lean On Me",
        "The Ultimate Collection (Remastered)"
      ]
  
      album_names.each do |album_name|
        Album.find_or_create_by(name: album_name)
      end
    end
  end
end