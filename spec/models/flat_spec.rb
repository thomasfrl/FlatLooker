require 'rails_helper'

RSpec.describe Flat, type: :model do
  10.times do
    FactoryBot.create(:flat)
  end

  context "validation" do

    it "is valid with valid attributes" do
      flat = FactoryBot.create(:flat)
      expect(flat).to be_a(Flat)
      expect(flat).to be_valid
    end

    describe "#surface" do
      it "should not be valid without surface" do
        bad_flat = FactoryBot.build(:flat, surface: nil)
        expect(bad_flat).not_to be_valid
        expect(bad_flat.errors.include?(:surface)).to eq(true)
      end

      it "should not be valid with a negatif surface" do
        bad_flat = FactoryBot.build(:flat, surface: -5)
        expect(bad_flat).not_to be_valid
        expect(bad_flat.errors.include?(:surface)).to eq(true)
      end
    end

    describe "#price" do
      it "should not be valid without price" do
        bad_flat = FactoryBot.build(:flat, price: nil)
        expect(bad_flat).not_to be_valid
        expect(bad_flat.errors.include?(:price)).to eq(true)
      end

      it "should not be valid with a negatif price" do
        bad_flat = FactoryBot.build(:flat, price: -5)
        expect(bad_flat).not_to be_valid
        expect(bad_flat.errors.include?(:price)).to eq(true)
      end
    end

    describe "#longitude" do
      it "should not be valid without longitude" do
        bad_flat = FactoryBot.build(:flat,longitude: nil)
        expect(bad_flat).not_to be_valid
        expect(bad_flat.errors.include?(:longitude)).to eq(true)
      end

      it "should not be valid with an outbounder longitude" do
        bad_flat = FactoryBot.build(:flat, longitude: -95)
        expect(bad_flat).not_to be_valid
        expect(bad_flat.errors.include?(:longitude)).to eq(true)
      end
    end

    describe "#latitude" do
      it "should not be valid without latitude" do
        bad_flat = FactoryBot.build(:flat,latitude: nil)
        expect(bad_flat).not_to be_valid
        expect(bad_flat.errors.include?(:latitude)).to eq(true)
      end

      it "should not be valid with an outbounder latitude" do
        bad_flat = FactoryBot.build(:flat, latitude: -95)
        expect(bad_flat).not_to be_valid
        expect(bad_flat.errors.include?(:latitude)).to eq(true)
      end
    end

    describe "#recommendated_flat_ids" do
      it "should have 4 elements" do
        flat = FactoryBot.create(:flat)
        flat.run_callbacks :create
        expect(flat.recommendated_flat_ids.size).to eq(4)
      end

      it "should be related to existing flats" do
        flat = FactoryBot.create(:flat)
        flat.run_callbacks :create
        expect(flat.recommendated_flat_ids.map {|id| Flat.try(:find_by_id, id)}).not_to include(nil)
      end
    end

  end

  context "callbacks" do

    describe "#associate_recommendation" do
      it "should associate 4 flats to the create one" do
        flat = FactoryBot.create(:flat)
        flat.run_callbacks :create
        expect(flat.recommendated_flat_ids.size).to eq(4)
      end
    end

  end

  context "public instance methods" do

    describe "#longitude_in_rad" do
      it "should return the longitude in rad" do
        flat = FactoryBot.create(:flat, longitude: 90)
        expect(flat.longitude_in_rad).to eq(Math::PI/2)
      end
    end
    describe "#latitude_in_rad" do
      it "should return the latitude in rad" do
        flat = FactoryBot.create(:flat, latitude: 90)
        expect(flat.latitude_in_rad).to eq(Math::PI/2)
      end
    end
    describe "#distance_to" do
      it "should return the distance between two flats" do
        flat = FactoryBot.create(:flat, longitude: 42, latitude: 10)
        flat2 = FactoryBot.create(:flat, longitude: 42, latitude: 10)
        flat3 = FactoryBot.create(:flat, longitude: 42, latitude: 11)
        flat4 = FactoryBot.create(:flat, longitude: 42, latitude: 12)

        expect(flat.distance_to(flat2).to_i).to eq(0)
        expect(flat.distance_to(flat3).to_i).to eq(111)
        expect(flat.distance_to(flat4).to_i).to eq(222)
      end
    end

    describe "#note" do
      it "should return the note between two flats" do
        flat = Flat.create(price:500, latitude: 42, longitude:10, surface: 50)
        flat2 = Flat.create(price:550, latitude: 42, longitude:10, surface: 50)
        flat3 = Flat.create(price:1000, latitude: 42, longitude:10, surface: 50)
        flat4 = Flat.create(price:500, latitude: 42, longitude:10, surface: 55)
        flat5 = Flat.create(price:500, latitude: 42, longitude:10, surface: 70)
        flat6 = Flat.create(price:500, latitude: 42.2, longitude:9, surface: 50)
        flat7 = Flat.create(price:500, latitude: 43, longitude:12, surface: 50)
        
        average_deviation_distance = Flat.average_deviation_distance
        average_deviation_price = Flat.average_deviation_price
        average_deviation_surface = Flat.average_deviation_surface

        expect(flat.note(flat2,average_deviation_distance, average_deviation_price, average_deviation_surface)).to be < flat.note(flat3,average_deviation_distance, average_deviation_price, average_deviation_surface)
        expect(flat.note(flat4,average_deviation_distance, average_deviation_price, average_deviation_surface)).to be < flat.note(flat5,average_deviation_distance, average_deviation_price, average_deviation_surface)
        expect(flat.note(flat6,average_deviation_distance, average_deviation_price, average_deviation_surface)).to be < flat.note(flat7,average_deviation_distance, average_deviation_price, average_deviation_surface)

      end
    end

    describe "#recommendations" do
      it "should return the 4 more simular flats ids" do
        flat = Flat.create(price:600, latitude: 44, longitude:5, surface: 30)
        flat2 = Flat.create(price:610, latitude: 44, longitude:5, surface: 30)
        flat3 = Flat.create(price:10000, latitude: 85, longitude:85, surface: 1000)
        average_deviation_distance = Flat.average_deviation_distance
        average_deviation_price = Flat.average_deviation_price
        average_deviation_surface = Flat.average_deviation_surface
        expect(flat.recommendations(average_deviation_distance, average_deviation_price, average_deviation_surface).size).to eq(4)
        expect(flat.recommendations(average_deviation_distance, average_deviation_price, average_deviation_surface).map {|id| Flat.try(:find_by_id, id)}).not_to include(nil)
        expect(flat.recommendations(average_deviation_distance, average_deviation_price, average_deviation_surface).map {|id| id.class}).to contain_exactly(Integer,Integer,Integer,Integer)
        expect(flat.recommendations(average_deviation_distance, average_deviation_price, average_deviation_surface)).to include(flat2.id)
        expect(flat.recommendations(average_deviation_distance, average_deviation_price, average_deviation_surface)).not_to include(flat3)
      end
    end
  end

  context "public class methods" do

    describe "self.average_deviation_distance" do
      it "should return a float" do
        expect(Flat.average_deviation_distance.class).to eq(Float)
      end
    end
    describe "self.average_deviation_surface" do
      it "should return a float" do
        expect(Flat.average_deviation_surface.class).to eq(Float)
      end
    end
    describe "self.average_deviation_price" do
      it "should return a float" do
        expect(Flat.average_deviation_price.class).to eq(Float)
      end
    end
  end
end




