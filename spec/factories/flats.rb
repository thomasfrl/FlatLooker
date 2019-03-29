FactoryBot.define do
  factory :flat do
    price { rand(300..3000) }
    surface { rand(9..300)}
    latitude { -5 + rand()*15 }
    longitude { 40 + rand()*10 }
  end
end
