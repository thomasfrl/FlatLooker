class Flat < ApplicationRecord
  validates :surface, :price, presence: true, numericality:  {greater_than_or_equal_to: 0}
  validates :longitude, :latitude, presence: true, numericality:  {greater_than_or_equal_to: -90, less_than_or_equal_to: 90}
  after_create :associate_recommendation
  after_update :associate_recommendation
  after_destroy :associate_recommendation
 
  def recommendated_flats
    self.recommendated_flat_ids.map {|id| Flat.find(id)}
  end

  def longitude_in_rad
    self.longitude/180*Math::PI
  end

  def latitude_in_rad
    self.latitude/180*Math::PI
  end

  def distance_to(other_flat)
    begin
      6378.137*Math.acos(Math.sin(self.latitude_in_rad)*Math.sin(other_flat.latitude_in_rad) + Math.cos(self.latitude_in_rad)*Math.cos(other_flat.latitude_in_rad)*Math.cos(other_flat.longitude_in_rad - self.longitude_in_rad))
    rescue StandardError => e
      puts e.class
      puts e.message
      return 0
    end
  end


  def self.average_deviation_distance
    average_deviation = 0
    flats = Flat.all
    n = flats.size
    flats.each do |flat|
      sum = 0
      flats.reject{|f| f == flat}.each do |flat_compared|
        sum += flat.distance_to(flat_compared)**2
      end
      deviation = (sum/n)**0.5
      average_deviation += deviation
    end
    average_deviation/n
  end

  def self.average_deviation_price
    average_deviation = 0
    flats = Flat.all
    n = flats.size
    flats.each do |flat|
      sum = 0
      flats.reject{|f| f == flat}.each do |flat_compared|
        sum += (flat.price - flat_compared.price)**2
      end
      deviation = (sum/n)**0.5
      average_deviation += deviation
    end
    average_deviation/n
  end

  def self.average_deviation_surface
    average_deviation = 0
    flats = Flat.all
    n = flats.size
    flats.each do |flat|
      sum = 0
      flats.reject{|f| f == flat}.each do |flat_compared|
        sum += (flat.surface - flat_compared.surface)**2
      end
      deviation = (sum/n)**0.5
      average_deviation += deviation
    end
    average_deviation/n
  end

  def note(other_flat, average_deviation_distance, average_deviation_price, average_deviation_surface)
   (self.price - other_flat.price).abs/average_deviation_price + (self.surface - other_flat.surface).abs/average_deviation_surface + (self.distance_to(other_flat))/average_deviation_distance
  end

  def recommendations(average_deviation_distance, average_deviation_price, average_deviation_surface)
    flats = Flat.all.reject{ |f| f == self}

    if flats.size > 4
      notes = []
      mins= []

      flats.each do |flat|
        value = self.note(flat, average_deviation_distance, average_deviation_price, average_deviation_surface)
        notes << {flat: flat.id, value: value}
      end

      4.times do
        min_note = notes.first
        notes.each do |note|
          if note[:value] < min_note[:value]
            min_note = note
          end
        end
        notes.delete(min_note)
        mins << min_note[:flat]
      end
      return mins
    else
      return flats.map {|flat| flat.id}
    end
  end

  def associate_recommendation
    if Flat.all.size > 0
      flat = Flat.last
      recommendated_flat_ids = flat.recommendations(Flat.average_deviation_distance, Flat.average_deviation_price, Flat.average_deviation_surface)
      flat.update_column(:recommendated_flat_ids, recommendated_flat_ids)
      AssociationFlatCreateJob.perform_later
    end
  end
end
