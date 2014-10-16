# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tip do
    payer "payer"
    payee "payee"
    amount 20
    currency :cny
    msg "@todamoon send @payee 1 yun"
    source 'weibo'
    deleted_at "2014-10-16 21:38:29"
  end
end
