class CreateFlats < ActiveRecord::Migration[5.2]
  def change
    create_table :flats do |t|
      t.float :price
      t.float :surface
      t.float :latitude
      t.float :longitude
      t.integer :recommendated_flat_ids, array: true, default: []
      t.timestamps
    end
    add_index :flats, :recommendated_flat_ids, using: 'gin'
  end
end
