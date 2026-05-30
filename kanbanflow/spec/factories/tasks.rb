FactoryBot.define do
  factory :task do
    association :project
    title       { Faker::Lorem.sentence(word_count: 4).first(100) }
    description { Faker::Lorem.paragraph }
    status      { :todo }
    position    { 1 }
  end
end
