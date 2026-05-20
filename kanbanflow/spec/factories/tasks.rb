FactoryBot.define do
  factory :task do
    project { nil }
    title { "MyString" }
    description { "MyText" }
    status { 1 }
    position { 1 }
  end
end
