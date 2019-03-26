class CreateRecommendations < ActiveRecord::Migration[5.2]
  def change
    create_table :recommendations do |t|
      t.references :recommendated_flat, index: true
      t.references :source_flat, index: true

      t.timestamps
    end
  end
end
