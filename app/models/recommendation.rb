class Recommendation < ApplicationRecord
  belongs_to :recommendated_flat, foreign_key: "recommendated_flat_id", class_name: "Flat"
  belongs_to :source_flat, foreign_key: "source_flat_id", class_name: "Flat"
end
