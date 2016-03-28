FactoryGirl.define do
  factory :photo do
    title 'My First Photo'
    description 'Hue hue hue, this is a description!'
    url_thumb 'http://placehold.it/150.jpg/09f/fff'
    url_medium 'http://placehold.it/600.jpg/09f/fff'
    url_large 'http://placehold.it/1000.jpg/09f/fff'
    url_original 'http://placehold.it/2000.jpg/09f/fff'
    external_service_id '1234'
    external_date 1.day.ago
    flickr

    trait :flickr do
      external_service_name 'flickr'
    end

    trait :instagram do
      external_service_name 'instagram'
    end
  end
end
