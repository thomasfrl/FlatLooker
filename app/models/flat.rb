class Flat < ApplicationRecord
  validates :surface, :longitude, :latitude, :price, presence: true, numericality:  {greater_than: 0}
  validates :longitude, :latitude, numericality:  {less_than: 90}
  # after_create :associate_recommendation
  # after_update :associate_recommendation
  # after_destroy :associate_recommendation

  has_many :recommendated_recommendations, foreign_key: :source_flat_id, class_name: "Recommendation"
  has_many :recommendated_flats, through: :recommendated_recommendations, source: :recommendated_flat

  has_many :source_recommendations, foreign_key: :recommendated_flat_id, class_name: "Recommendation"
  has_many :source_flats, through: :source_recommendations, source: :source_flat
 
  def longitude_in_rad
    self.longitude/180*Math::PI
  end

  def latitude_in_rad
    self.longitude/180*Math::PI
  end

  def distance_to(other_flat)
    begin
      6378*Math.acos(Math.sin(self.latitude_in_rad)*Math.sin(other_flat.latitude_in_rad) + Math.cos(self.latitude_in_rad)*Math.cos(other_flat.latitude_in_rad)*Math.cos(other_flat.longitude_in_rad - self.longitude_in_rad))
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

  def recommendations
    flats = Flat.all.reject{ |f| f == self}

    if flats.size > 4
      average_deviation_price = Flat.average_deviation_price
      average_deviation_surface = Flat.average_deviation_surface
      average_deviation_distance = Flat.average_deviation_distance

      notes = []
      mins= []

      flats.each do |flat|
        notes << [flat.id, self.note(flat, average_deviation_distance, average_deviation_price, average_deviation_surface)]
      end

      4.times do
        min_note = notes.first
        min_value = min_note[1]
        notes.each do |note|
          if note[1] < min_value
            min_value = note[1]
            min_note = note
          end
        end
        notes.delete(min_note)
        mins << Flat.find(min_note[0])
      end
      return mins
    else
      return flats
    end
  end

  def associate_recommendation
    Recommendation.destroy_all
    Flat.all.each do |flat|
      flat.recommendations.each do |other_flat|
        Recommendation.create(recommendated_flat: other_flat, source_flat: flat)
      end
    end
  end
end
