FactoryBot.define do
  factory :project do
    user { nil }
    name { "MyString" }
    description { "MyText" }
    color { "MyString" }
  end
end
