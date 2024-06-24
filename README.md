## Recommender Gem

The `Recommender` gem is a versatile recommendation engine built for Ruby on Rails applications. It leverages collaborative filtering techniques to generate personalized recommendations based on user interactions and similarities. This gem supports various association types, including `has_and_belongs_to_many`, `has_many :through`, and `has_many`, making it flexible and easy to integrate into different relational database models.

### Features

- **Advanced Similarity Measures:** Utilizes the Jaccard Index, Dice-Sørensen Coefficient, and custom collaborative weighting to provide highly accurate recommendations. These measures calculate the similarity between users based on their shared preferences.
- **Multiple Association Support:** Compatible with `has_and_belongs_to_many`, `has_many :through`, and `has_many` associations, allowing seamless integration with different data models.
- **Customizable Recommendations:** Easily extendable and configurable to fit the specific needs of your application.
- **Lightweight and Efficient:** Designed to be efficient and minimalistic, ensuring fast recommendation calculations without heavy overhead.
- Feature: Similarity based on multiple associations combined with weights.
- Feature: User-item recommendations based on all their items.
- Feature: Recommendations based on a weighted mix of various associations.

### Installation

Add this line to your application's Gemfile:

`gem 'recommender'`

And then execute:

`bundle install`

### Usage

Include the `Recommender::Recommendation` module in your model and set the association:

```
class Album < ApplicationRecord
  include Recommender::Recommendation
  has_and_belongs_to_many :users
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  set_association users: 2.0
end
```

Now you can get recommendations for an instance:

```
user = User.find(1)
recommendations = user.recommendations(results: 5)
recommendations.each do |recommended_album, score|
  puts "#{recommended_album.name} - Score: #{score}"
end
```

### How It Works

The gem computes recommendations by comparing the preferences of different users. It uses the following measures to calculate similarity:

- **Jaccard Index:** Measures the similarity between two sets by dividing the size of the intersection by the size of the union of the sets.
- **Dice-Sørensen Coefficient:** Calculates similarity as twice the size of the intersection divided by the sum of the sizes of the two sets.
- **Collaborative Weighting:** Further refines recommendations by considering the commonality and diversity of preferences.

These measures are combined to generate a final similarity score, which is then used to recommend items that the user has not yet interacted with but are popular among similar users.

### Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/Mutuba/recommender](https://github.com/yourusername/recommender). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the Contributor Covenant code of conduct.

### License

The gem is available as open source under the terms of the MIT License.
