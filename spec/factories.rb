require 'faker'

FactoryBot.define do
  factory :language do
    short { 'en' }
    name { 'English' }
  end

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

    factory :confirmed_user do
      confirmed_at { Time.now }
    end
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

  factory :work do
    title    { Faker::Lorem.words(number: 4).join(" ") }
    summary  { Faker::Lorem.sentences(number: 3).join(" ") }
    notes    { Faker::Lorem.sentences(number: 4).join(" ") }
    endnotes { Faker::Lorem.sentences(number: 4).join(" ") }
    posted { true }
    restricted { false }
    language
  end

  factory :chapter do
    position { 1 }
    content { Faker::Lorem.paragraphs(number: 5).join("\n\n") }
  end

  factory :draft do
    title { Faker::Lorem.words(number: 4).join(" ") }
  end

  factory :series do
    title { Faker::Lorem.words(number: 6).to_s }
  end

  factory :collection do
    name { Faker::Lorem.characters(number: 8).to_s }
    title { Faker::Lorem.characters(number: 8).to_s }
  end
end
