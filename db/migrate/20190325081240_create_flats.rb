class CreateFlats < ActiveRecord::Migration[5.2]
  def change
    create_table :flats do |t|
      t.float :price
      t.float :surface
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
