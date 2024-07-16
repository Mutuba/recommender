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

        @association_metadata ||= build_association_metadata(reflection)
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
            reflection.klass.table_name,
            reflection.foreign_key,
            reflection.foreign_key,
            reflection.name,
          )
        else
          raise ArgumentError, "Association '#{reflection.name}' is not a supported type"
        end
      end
    end

    def recommendations(results: 10)
      other_instances = self.class.where.not(id: id)

      self_items = associated_items.to_set

      item_recommendations = calculate_recommendations(other_instances, self_items)

      sorted_recommendation_ids = sort_recommendations(item_recommendations).take(results)

      fetch_recommendation_objects(sorted_recommendation_ids, item_recommendations)
    end

    private

    def associated_items
      send(self.class.association_metadata.reflection_name).pluck(self.class.association_metadata.association_foreign_key)
    end

    def calculate_recommendations(other_instances, self_items)
      other_instances.each_with_object(Hash.new(0)) do |instance, acc|
        instance_items = instance.send(self.class.association_metadata.reflection_name).pluck(self.class.association_metadata.association_foreign_key).to_set
        common_items = instance_items & self_items

        weight = calculate_weight(common_items, instance_items, self_items)

        (instance_items - common_items).each do |item_id|
          acc[item_id] += weight unless self_items.include?(item_id)
        end
      end
    end

    def calculate_weight(common_items, instance_items, self_items)
      jaccard_index = common_items.size.to_f / (instance_items | self_items).size
      dice_sorensen_coefficient = (2.0 * common_items.size) / (instance_items.size + self_items.size)
      collaborative_weight = common_items.size.to_f / Math.sqrt(instance_items.size * self_items.size)

      (jaccard_index + dice_sorensen_coefficient + collaborative_weight) / 3.0
    end

    def sort_recommendations(item_recommendations)
      item_recommendations.keys.sort_by { |id| item_recommendations[id] }.reverse
    end

    def fetch_recommendation_objects(sorted_recommendation_ids, item_recommendations)
      association = self.class.reflect_on_association(self.class.association_metadata.reflection_name)
      association_table = association.klass

      sorted_recommendation_ids.map do |id|
        value = item_recommendations[id]
        [association_table.find(id), value.is_a?(Float) && value.nan? ? 0 : value]
      end
    end
  end
end
