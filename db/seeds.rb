Recommendation.destroy_all
Flat.destroy_all

100.times do 
  Flat.create(longitude: rand()*90, latitude: rand()*90, price: rand(300..3000),surface: rand(9..300))
end

