require 'faker'

FactoryBot.define do
  sequence(:login) do |n|
    "#{Faker::Lorem.characters(number: 8)}#{n}"
  end

  sequence :email do |n|
    Faker::Internet.email(name: "#{Faker::Name.first_name}_#{n}")
  end

  factory :user do
    login { generate(:login) }
    password { "password" }
    password_confirmation { |u| u.password }
    email { generate(:email) }
  end

  factory :pseud do
    name { generate(:login) }
    is_default { true }
    user
  end

  factory :profile do
    user
  end

  factory :preference do
    user
  end

  factory :freeform do
    name { Faker::Books::Lovecraft.word }
  end
end
