FactoryBot.define do
  factory :project do
    association :user
    name        { Faker::App.name.first(50) }
    description { Faker::Lorem.sentence }
    color       { Project::COLORS.sample }
  end
end
