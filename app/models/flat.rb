class Flat < ApplicationRecord
  # 5 attribut accessor : 
  #   surface:float (m²) , 
  #   price:float (€) , 
  #   longitude:float (°), 
  #   latitude:float (°), 
  #   recommendated_flat_ids (array of flat_id)
  #
  # 6 public instance methodes : 
  #   recommendated_flats -> array of flat
  #   longitude_in_rad -> float
  #   latitude_in_rad -> float
  #   distance_to(other_flat) -> float
  #   note(other_flat, average_deviation_distance, average_deviation_price, average_deviation_surface) -> float
  #   recommendations (other_flat, average_deviation_distance, average_deviation_price, average_deviation_surface) -> array of integer
  #
  # 3 public class methodes :
  #   average_deviation_distance -> float
  #   average_deviation_price -> float
  #   average_deviation_surface -> float



  validates :surface, :price, presence: true, numericality:  {greater_than_or_equal_to: 0}
  validates :longitude, :latitude, presence: true, numericality:  {greater_than_or_equal_to: -90, less_than_or_equal_to: 90}
  after_create :associate_recommendation
  after_update :associate_recommendation
  after_destroy :associate_recommendation
 
  def recommendated_flats
    # recommendated_flats ->  array of flat
    # it return the flats associated to the flat_ids contained in the attribut "recommendated_flat_ids"
    # example:
    # flat = Flat.create(surface: 50, price: 500, longitude: 24, latitude: 45)
    # flat.recommendated_flat_ids #=> [flat1_id, flat2_id, flat3_id, flat4_id]
    # flat.recommendated_flats #=> [flat1, flat2, flat3, flat4]

    self.recommendated_flat_ids.map {|id| Flat.find(id)}
  end

  def longitude_in_rad
    # longitude_in_rad -> float
    # it return the longitude in radians associated to the flat
    # example:
    # flat = Flat.create(surface: 50, price: 500, longitude: 24, latitude: 45)
    # flat.longitude_in_rad #=> 0.41887902

    self.longitude/180*Math::PI
  end

  def latitude_in_rad
    # latitude_in_rad -> float
    # it return the latitude in radians associated to the flat
    # example:
    # flat = Flat.create(surface: 50, price: 500, longitude: 24, latitude: 45)
    # flat.latitude_in_rad #=> 0.785398163

    self.latitude/180*Math::PI
  end

  def distance_to(other_flat)
    # distance_to(other_flat) -> float
    # it takes in argument a flat which gonna be compared to the flat on which the methode is applied
    # it returns the distance between the two flats in km
    # example : 
    # flat = Flat.create(surface: 50, price: 500, longitude: 24, latitude: 45)
    # flat2 = Flat.create(surface: 50, price: 500, longitude: 24, latitude: 46)
    # flat.distance_to(flat2) #=> 111

    begin
      6378.137*Math.acos(Math.sin(self.latitude_in_rad)*Math.sin(other_flat.latitude_in_rad) + Math.cos(self.latitude_in_rad)*Math.cos(other_flat.latitude_in_rad)*Math.cos(other_flat.longitude_in_rad - self.longitude_in_rad))
    rescue StandardError => e
      puts e.class
      puts e.message
      return 0
    end
  end


  def self.average_deviation_distance
    # average_deviation_distance -> float
    # it return the average of the deviation of the distance of all the flats
    # example:
    # 10.times {Flat.create(longitude: -5 + rand()*15, latitude: 40 + rand()*10, price: rand(300..3000),surface: rand(9..300))}
    # Flat.average_deviation_distance #=> float
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
    # average_deviation_price -> float
    # it return the average of the deviation of the price of all the flats
    # example:
    # 10.times {Flat.create(longitude: -5 + rand()*15, latitude: 40 + rand()*10, price: rand(300..3000),surface: rand(9..300))}
    # Flat.average_deviation_price #=> float

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
    # average_deviation_surface -> float
    # it return the average of the deviation of the surface of all the flats
    # example:
    # 10.times {Flat.create(longitude: -5 + rand()*15, latitude: 40 + rand()*10, price: rand(300..3000),surface: rand(9..300))}
    # Flat.average_deviation_surface #=> float

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
    # note(other_flat, average_deviation_distance, average_deviation_price, average_deviation_surface) -> float
    # it takes in arguments :  
    # - the average of the deviation of the distances between all the flats in the database
    # - the average of the deviation of the prices between all the flats in the database
    # - the average of the deviation of the surface between all the flats in the database
    # - a flat which gonna be compared to the flat on which the methode is applied
    # it returns a note which evaluate the simularity between the two flat (0 means they are identique and the bigger it is, the more different it is)
    # example:
    # flat = Flat.create(surface: 50, price: 500, longitude: 24, latitude: 45)
    # flat2 = Flat.create(surface: 50, price: 500, longitude: 24, latitude: 46)
    # flat.note(flat2,Flat.average_deviation_distance, Flat.average_deviation_price, Flat.average_deviation_surface) #=> a float greater than 0


   (self.price - other_flat.price).abs/average_deviation_price + (self.surface - other_flat.surface).abs/average_deviation_surface + (self.distance_to(other_flat))/average_deviation_distance
  end

  def recommendations(average_deviation_distance, average_deviation_price, average_deviation_surface)
    # recommendations (other_flat, average_deviation_distance, average_deviation_price, average_deviation_surface) -> array of integer    # it takes in arguments :  
    # - the average of the deviation of the distances between all the flats in the database
    # - the average of the deviation of the prices between all the flats in the database
    # - the average of the deviation of the surface between all the flats in the database
    # it returns a array of the ids of the 4 most simular flats of all the flats in the database
    # example:
    # flat = Flat.create(surface: 50, price: 500, longitude: 24, latitude: 45)
    # flat.recommendations(Flat.average_deviation_distance, Flat.average_deviation_price, Flat.average_deviation_surface) #=> [simular_flat1_id, simular_flat2_id, simular_flat3_id, simular_flat4_id]

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

  private
  def associate_recommendation
    # it modify all the flat database by associating the 4 more simular flats to each fat of the database
    # for each flat, the attribute recommendated_flat_ids is updated
    if Flat.all.size > 0
      flat = Flat.last
      recommendated_flat_ids = flat.recommendations(Flat.average_deviation_distance, Flat.average_deviation_price, Flat.average_deviation_surface)
      flat.update_column(:recommendated_flat_ids, recommendated_flat_ids)
      AssociationFlatCreateJob.perform_later
    end
  end
end
