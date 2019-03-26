Recommendation.destroy_all
Flat.destroy_all

100.times do 
  Flat.create(longitude: -5 + rand()*15, latitude: 40 + rand()*10, price: rand(300..3000),surface: rand(9..300))
end

