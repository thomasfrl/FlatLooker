class AssociationFlatCreateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Recommendation.destroy_all
    Flat.all.each do |flat|
      flat.recommendations.each do |other_flat|
        Recommendation.create(recommendated_flat: other_flat, source_flat: flat)
      end
    end
  end
end
