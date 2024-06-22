# frozen_string_literal: true

require "active_support/concern"

module Recommender
  module Recommendation
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    AssociationMetaData = Struct.new("AssociationMetaData", :join_table, :foreign_key, :association_foreign_key, :reflection_name, :weight)

    module ClassMethods
      attr_accessor :association_meta_data

      def set_associations(associations)        
        @association_meta_data = associations.map do |association_name, weight|          
          reflection = reflect_on_association(association_name.to_sym)
          raise ArgumentError, "Association '#{association_name}' not found" unless reflection

          build_association_meta_data(reflection, weight)
        end
      end

      private

      def build_association_meta_data(reflection, weight)
        case reflection
        when ActiveRecord::Reflection::HasAndBelongsToManyReflection
          AssociationMetaData.new(
            reflection.join_table,
            reflection.foreign_key,
            reflection.association_foreign_key,
            reflection.name,
            weight
          )
        when ActiveRecord::Reflection::ThroughReflection
          AssociationMetaData.new(
            reflection.through_reflection.table_name,
            reflection.through_reflection.foreign_key,
            reflection.association_foreign_key,
            reflection.name,
            weight
          )
        when ActiveRecord::Reflection::HasManyReflection
          AssociationMetaData.new(
            reflection.klass.table_name,
            reflection.foreign_key,
            reflection.foreign_key,
            reflection.name,
            weight
          )
        else
          raise ArgumentError, "Association '#{reflection.name}' is not a supported type"
        end
      end
    end

    def recommendations(results: 5)
      other_instances = self.class.where.not(id: id)
      item_recommendations = other_instances.reduce(Hash.new(0)) do |acc, instance|
        self.class.association_meta_data.each do |meta_data|          
          self_items = send(meta_data.reflection_name).pluck(:id).to_set
          instance_items = instance.send(meta_data.reflection_name).pluck(:id).to_set
          common_items = self_items & instance_items

          jaccard_index = common_items.size.to_f / (self_items | instance_items).size
          dice_sorensen_coefficient = (2.0 * common_items.size) / (self_items.size + instance_items.size)
          collaborative_weight = common_items.size.to_f / Math.sqrt(self_items.size * instance_items.size)

          # Calculate weighted score for this association
          association_weighted_score = meta_data.weight * (jaccard_index + dice_sorensen_coefficient + collaborative_weight) / 3.0

          # Recommend items based on this association
          (instance_items - common_items).each do |item_id|
            acc[item_id] += association_weighted_score unless self_items.include?(item_id)
          end
        end

        acc
      end

      sorted_recommendation_ids = item_recommendations.keys.sort_by { |id| item_recommendations[id] }.reverse.take(results)
      association_table = self.class.reflect_on_association(self.class.association_meta_data.first.reflection_name).klass
      sorted_recommendation_ids.map { |id| [association_table.find(id), item_recommendations[id]] }
    end
  end
end
