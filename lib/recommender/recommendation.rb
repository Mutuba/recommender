# frozen_string_literal: true

require "active_support/concern"

module Recommender
  module Recommendation
    extend ActiveSupport::Concern
  
    included do
      extend ClassMethods
    end
  
    AssociationMetadata = Struct.new(:join_table, :foreign_key, :association_foreign_key, :reflection_name)
  
    module ClassMethods
      attr_accessor :association_metadata
  
      def set_association(association_name)
        reflection = reflect_on_association(association_name.to_sym)
        raise ArgumentError, "Association '#{association_name}' not found" unless reflection
              
        self.association_metadata = build_association_metadata(reflection)
      end
  
      private
  
      def build_association_metadata(reflection)
        case reflection
        when ActiveRecord::Reflection::HasAndBelongsToManyReflection
          AssociationMetadata.new(
            reflection.join_table,
            reflection.foreign_key,
            reflection.association_foreign_key,
            reflection.name
          )
        when ActiveRecord::Reflection::ThroughReflection
          AssociationMetadata.new(
            reflection.through_reflection.table_name,
            reflection.through_reflection.foreign_key,
            reflection.association_foreign_key,
            reflection.name
          )
        when ActiveRecord::Reflection::HasManyReflection
          AssociationMetadata.new(
            reflection.name.to_s.pluralize,
            reflection.foreign_key,
            nil,
            reflection.name
          )
        else
          raise ArgumentError, "Association '#{reflection.name}' is not a supported type"
        end
      end
    end
  
    def recommendations(results: 10)
      other_instances = self.class.where.not(id: id)
      self_items = send(self.class.association_metadata.join_table).pluck(self.class.association_metadata.association_foreign_key).to_set
  
      item_recommendations = other_instances.reduce(Hash.new(0)) do |acc, instance|
        instance_items = instance.send(self.class.association_metadata.join_table).pluck(self.class.association_metadata.association_foreign_key).to_set
        common_items = instance_items & self_items
  
        # Calculate similarity scores using the Jaccard Index and Dice-Sørensen Coefficient
        jaccard_index = common_items.size.to_f / (instance_items | self_items).size
        dice_sorensen_coefficient = (2.0 * common_items.size) / (instance_items.size + self_items.size)
  
        # Calculate collaborative filtering weight and normalize it accordingly
        collaborative_weight = common_items.size.to_f / Math.sqrt(instance_items.size * self_items.size)
  
        # Combine the similarity scores with the collaborative filtering weight
        weight = (jaccard_index + dice_sorensen_coefficient + collaborative_weight) / 3.0
  
        (instance_items - common_items).each do |item_id|
          # Exclude items that are already liked by the user
          acc[item_id] += weight unless self_items.include?(item_id)
        end
        acc
      end
  
      # Fetch the movie objects and pair them with their recommendation scores
      sorted_recommendation_ids = item_recommendations.keys.sort_by { |id| item_recommendations[id] }.reverse.take(results)

      association_table = self.class.reflect_on_association(self.class.association_metadata.reflection_name).klass
      sorted_recommendation_ids.map { |id| [association_table.find(id), item_recommendations[id]] }
    end
  end
end
