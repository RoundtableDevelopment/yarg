FactoryBot.define do
  factory :user do
    sequence :email do |n|
      "user#{n}@mail.com"
    end
    password '11111111'
  end
end
