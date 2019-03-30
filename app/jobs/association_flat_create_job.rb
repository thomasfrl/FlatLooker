class AssociationFlatCreateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    average_deviation_price = Flat.average_deviation_price
    average_deviation_surface = Flat.average_deviation_surface
    average_deviation_distance = Flat.average_deviation_distance
    Flat.all.each do |flat|
      recommendated_flat_ids = flat.recommendations(average_deviation_distance, average_deviation_price, average_deviation_surface)
      flat.update_column(:recommendated_flat_ids, recommendated_flat_ids)
    end
  end
end
