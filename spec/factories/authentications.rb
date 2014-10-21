# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authentication do
    provider "weibo"
    uid { Faker::Number.number(15).to_s }
    token "2.0token"
    secret "secret"
    member { create(:member) }
  end
end
